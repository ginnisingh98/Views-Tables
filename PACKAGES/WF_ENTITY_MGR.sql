--------------------------------------------------------
--  DDL for Package WF_ENTITY_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ENTITY_MGR" AUTHID CURRENT_USER as
/* $Header: WFEMGRS.pls 120.1.12010000.2 2010/03/09 20:55:30 alsosa ship $ */
------------------------------------------------------------------------------
/*
** process_changes - This procedure checks the attribute cache for changes
**                   to this particular entity.  If none, exits.
**                   Otherwise, updates LDAP (if present) and raises the
**                   "oracle.apps.global.<entity_type>.change" event.
**                   (or optionally the event you specify in p_event_name)
**
**                   Usually called after a series of put_attribute_value()
**                   calls.  This is how you inform the entity manager that
**                   this particular entity may have recent changes to
**                   propagate.
**
**                   Change source identifies the source of the change
**                   so that echoes of your own changes can be ignored.
**                   Standard change source is <package>.<procedure>.
**                   For example, "FND_USER_PKG.UPDATE_USER"
**
**                   Change type can currently be LOAD or DELETE.
**
**                   The optional event_name parameter is to specify the event
**                   you would like entmgr to raise if you are not satisfied
**                   with the standard derived name of
**                     oracle.apps.global.'||lower(p_entity_type)||'.change'
*/
PROCEDURE process_changes(p_entity_type      in varchar2,
                          p_entity_key_value in varchar2,
                          p_change_source    in varchar2,
                          p_change_type      in varchar2 default 'LOAD',
                          p_event_name       in varchar2 default null);
------------------------------------------------------------------------------
/*
** get_attribute_value - fetch an entity attribute value from the
**                       attribute cache.
*/
FUNCTION get_attribute_value(p_entity_type      in varchar2,
                             p_entity_key_value in varchar2,
                             p_attribute        in varchar2) return varchar2;
------------------------------------------------------------------------------
/*
** put_attribute_value - set an entity attribute value into the
**                       attribute cache.  Does nothing if new value is
**                       equal to current or null.  Otherwise, sets the new
**                       value and updates the internal CACHE_CHANGED
**                       attribute to "YES".
**
**                       Non-varchar2 attribute values must be converted
**                       to their cannonical varchar2 equivalent values
**                       using standard conversion conventions.
**
**                          FND_DATE.date_to_canonical()
**                          FND_NUMBER.number_to_canonical().
**
**                       Use "*NULL*" to indicate a null value.
*/
PROCEDURE put_attribute_value(p_entity_type      in varchar2,
                              p_entity_key_value in varchar2,
                              p_attribute        in varchar2,
                              p_attribute_value  in varchar2);
------------------------------------------------------------------------------
/*
** flush_cache - Deletes cached records that match the specified
**               entity info.  The special entity_type "*ALL*" will
**               truncate the entire table.
*/
PROCEDURE flush_cache(p_entity_type      in varchar2 default null,
                      p_entity_key_value in varchar2 default null);
------------------------------------------------------------------------------
/*
** get_entity_type - fetch the entity type from an entmgr event name.
**                   Should be kept in synch with the code in process_changes()
**                   which derives the event name to raise.
*/
FUNCTION get_entity_type(p_event_name in varchar2) return varchar2;
------------------------------------------------------------------------------
/*
** gen_xml_payload - construct the xml equivalent of the cached attribute
**                   data for the event payload.  Useful for folks who
**                   don't have access to the attribute cache or who need
**                   to persist the data for more than one transaction.
*/
FUNCTION gen_xml_payload(p_event_name in varchar2,
                         p_event_key  in varchar2) return clob;
------------------------------------------------------------------------------
/*
** isChanged - compare new and existing attribute values, taking into account
**             special values *NULL* and *UNKNOWN*
*/
FUNCTION isChanged(p_new_val in varchar2,
                   p_old_val in varchar2) return boolean;
------------------------------------------------------------------------------
/*
** purge_cache_attributes - This procedure purges/removes obsolete data from
**                  table WF_ATTROBITE_CACHE based on the age parameter
**                  specified in the concurrent program FNDWFPRG
**                  This proceduce is added as per the fix to bug 5576885.
*/
PROCEDURE purge_cache_attributes (p_enddate date);
------------------------------------------------------------------------------
end WF_ENTITY_MGR;

/
