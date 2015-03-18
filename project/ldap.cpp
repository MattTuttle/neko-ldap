#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <sys/time.h>
#include <iostream>

#define LDAP_DEPRECATED 1
#include <ldap.h>

#define ERROR_MSG_SIZE 1024
#define LDAP_ATTRS_MAX_SIZE 1024

vkind k_ldap_pointer;

extern char* tls_opt_cacertfile;

void nekoldap_error(char *tmplte, char *error_string)
{
	char msg[ERROR_MSG_SIZE];
	sprintf(msg, tmplte, error_string);
	std::cout << msg << std::endl;
	std::exit(1);
}

value nekoldap_connect(value uri)
{
	LDAP *ldap;
	int rc;

	val_check(uri, string);
	rc = ldap_initialize(&ldap, val_string(uri));
	if (rc == LDAP_SUCCESS)
	{
		return alloc_abstract(k_ldap_pointer, ldap);
	}
	val_throw(alloc_int(rc));
	return alloc_null();
}

value nekoldap_set_option(value neko_ldap, value neko_option, value neko_newval)
{
	int result;
	LDAP *ldap;
	int option;
	int newval;

	if (val_is_kind(neko_ldap, k_ldap_pointer))
	{
		ldap = (LDAP *)val_to_kind(neko_ldap, k_ldap_pointer);
	}
	else
	{
		ldap = NULL;
	}
	val_check(neko_option, int);
	option = val_int(neko_option);

	switch (option)
	{
		case LDAP_OPT_PROTOCOL_VERSION:
		case LDAP_OPT_REFERRALS:
		case LDAP_OPT_DEBUG_LEVEL:
			if (! val_is_int(neko_newval)) break;
			newval = val_int(neko_newval);
			result = ldap_set_option(ldap, option, &newval);
			break;
		case LDAP_OPT_NETWORK_TIMEOUT:
			if (! val_is_object(neko_newval)) break;
			struct timeval tv;
			tv.tv_sec = val_int(val_field(neko_newval,val_id("sec")));
			tv.tv_usec = val_int(val_field(neko_newval,val_id("usec")));
			result = ldap_set_option(ldap, option, &tv);
			break;
		default:
			result = LDAP_OPT_ERROR;
			break;
	}

	return alloc_int(result);
}

value nekoldap_bind(value ldap, value dn, value password)
{
	int rc;

	val_check_kind(ldap, k_ldap_pointer);
	val_check(dn, string);
	val_check(password, string);

	rc = ldap_bind_s((LDAP *)val_to_kind(ldap, k_ldap_pointer), val_string(dn), val_string(password), LDAP_AUTH_SIMPLE);
	if (rc == LDAP_SUCCESS)
	{
		return alloc_bool(TRUE);
	}
	val_throw(alloc_int(rc));
	return alloc_bool(FALSE);
}


value nekoldap_unbind(value ldap)
{
	val_check_kind(ldap, k_ldap_pointer);
	return alloc_int(ldap_unbind((LDAP *)val_to_kind(ldap, k_ldap_pointer)));
}

value getLDAPEntries(LDAP *ldap, LDAPMessage *ldap_result)
{
	LDAPMessage *ldap_result_entry;
	value neko_result = alloc_null();

	int num_entries, num_values, i;
	BerElement *ber;
	char *attribute;
	struct berval **ldap_value;
	char *dn;

	num_entries = ldap_count_entries(ldap, ldap_result);
	if (num_entries != 0)
	{
		neko_result = alloc_array(num_entries);
		num_entries = 0;

		ldap_result_entry = ldap_first_entry(ldap, ldap_result);
		while (ldap_result_entry != NULL)
		{
			value item = alloc_empty_object();

			attribute = ldap_first_attribute(ldap, ldap_result_entry, &ber);
			while (attribute != NULL)
			{
				ldap_value = ldap_get_values_len(ldap, ldap_result_entry, attribute);
				num_values = ldap_count_values_len(ldap_value);

				value attrib_array = alloc_array(num_values);
				value *attributes = val_array_value(attrib_array);
				for (i = 0; i < num_values; i++)
				{
					attributes[i] = alloc_string(ldap_value[i]->bv_val);
				}
				ldap_value_free_len(ldap_value);

				alloc_field(item, val_id(attribute), attrib_array);
				ldap_memfree(attribute);
				attribute = ldap_next_attribute(ldap, ldap_result_entry, ber);
			}
			if (ber != NULL)
			{
				ber_free(ber, 0);
			}

			dn = ldap_get_dn(ldap, ldap_result_entry);
			alloc_field(item, val_id("dn"), alloc_string(dn));
			ldap_memfree(dn);
			val_array_value(neko_result)[num_entries++] = item;
			ldap_result_entry = ldap_next_entry(ldap, ldap_result_entry);
		}
	}

	return neko_result;
}

value nekoldap_search(value *args, int nargs)
{
	int i, rc;

	if (nargs != 6) neko_error();

	val_check_kind(args[0], k_ldap_pointer);
	LDAP *ldap  = (LDAP *)val_to_kind(args[0], k_ldap_pointer);

	val_check(args[1], string);
	const char *base = val_string(args[1]);

	val_check(args[2], int);
	int scope = val_int(args[2]);

	val_check(args[3], string);
	const char *filter = val_string(args[3]);

	const char *ch_attrs[LDAP_ATTRS_MAX_SIZE];
	if (!val_is_null(args[4]))
	{
		val_check(args[4], array);
		value *v_attrs = val_array_value(args[4]);
		for (i = 0; i < val_array_size(args[4]); i++)
		{
			val_check(v_attrs[i], string);
			ch_attrs[i] = val_string(v_attrs[i]);
		}
		ch_attrs[i]=0;
	}

	val_check(args[5], int);
	int attrsonly = val_int(args[5]);

	LDAPMessage *res;

	rc = ldap_search_s(ldap, base, scope, filter, (char **)ch_attrs, attrsonly, &res);
	if (rc != LDAP_SUCCESS)
	{
		val_throw(alloc_int(rc));
		return alloc_null();
	}

	return getLDAPEntries(ldap, res);
}

value nekoldap_err2string(value result)
{
	val_check(result, int);
	return alloc_string(ldap_err2string(val_int(result)));
}

void getModificationsCountFromNekoObject(value v, field f, void *count)
{
	(*(int *)count)++;
}

typedef struct _AttributesGetLdapModificationsFromNekoObject
{
	int i;
	int operation;
	LDAPMod **mods;
} AttributesGetLdapModificationsFromNekoObject;

void getLdapModificationsFromNekoObject(value v, field f, void *p)
{
	AttributesGetLdapModificationsFromNekoObject *attrs = (AttributesGetLdapModificationsFromNekoObject *) p;

	val_check(v, string);
	std::cout << val_string(val_field_name(f)) << " = " << val_string(v) << std::endl;

	attrs->mods[attrs->i] = (LDAPMod *)malloc(sizeof(LDAPMod));
	attrs->mods[attrs->i]->mod_op = attrs->operation | LDAP_MOD_BVALUES;
	attrs->mods[attrs->i]->mod_type = strdup(val_string(val_field_name(f)));
	printf("mods[%d]->mod_type=%s\n", attrs->i, attrs->mods[attrs->i]->mod_type);

	if (val_is_string(v))
	{
		attrs->mods[attrs->i]->mod_bvalues = (struct berval **) malloc (2*sizeof(struct berval *));
		attrs->mods[attrs->i]->mod_bvalues[0] = (struct berval *) malloc (sizeof(struct berval));
		attrs->mods[attrs->i]->mod_bvalues[0]->bv_len = strlen(val_string(v));
		attrs->mods[attrs->i]->mod_bvalues[0]->bv_val = strdup(val_string(v));
		attrs->mods[attrs->i]->mod_bvalues[1] = NULL;
		printf("berval: len=%ld val=%s\n", attrs->mods[attrs->i]->mod_bvalues[0]->bv_len, attrs->mods[attrs->i]->mod_bvalues[0]->bv_val);
	}
	else if (val_is_array(v))
	{
		std::cout << "Array values not implemented." << std::endl;
		std::exit(1);
	}
	attrs->i++;
}


value nekoldap_modify(value neko_ldap, value neko_dn, value neko_mods, value neko_operation)
{
	val_check_kind(neko_ldap, k_ldap_pointer);
	val_check(neko_dn, string);

	val_check(neko_operation, int);
	int operation = val_int(neko_operation);

	val_check(neko_mods, object);

	int modifications_count = 0;

	val_iter_fields(neko_mods, getModificationsCountFromNekoObject, (void *)&modifications_count);

	std::cout << "count = " << modifications_count << std::endl;

	AttributesGetLdapModificationsFromNekoObject attrs;
	attrs.mods = (LDAPMod **)malloc((modifications_count+1)*sizeof(LDAPMod *));
	memset(attrs.mods, 0, sizeof(LDAPMod *)*(modifications_count+1));
	attrs.i = 0;
	attrs.operation = operation;

	val_iter_fields(neko_mods, getLdapModificationsFromNekoObject, (void *)&attrs);
	attrs.mods[modifications_count] = NULL;

	int rc = ldap_modify_s((LDAP *)val_to_kind(neko_ldap, k_ldap_pointer), val_string(neko_dn), attrs.mods);
	if (rc != LDAP_SUCCESS)
	{
		val_throw(alloc_int(rc));
		return alloc_bool(FALSE);
	}
	else
	{
		return alloc_bool(TRUE);
	}

}


DEFINE_PRIM(nekoldap_connect, 1);
DEFINE_PRIM(nekoldap_bind, 3);
DEFINE_PRIM(nekoldap_unbind, 1);
DEFINE_PRIM_MULT(nekoldap_search);
DEFINE_PRIM(nekoldap_err2string, 1);
DEFINE_PRIM(nekoldap_modify, 4);
DEFINE_PRIM(nekoldap_set_option, 3);
