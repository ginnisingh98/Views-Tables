--------------------------------------------------------
--  DDL for Package BISM_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BISM_CORE" AUTHID CURRENT_USER as
/* $Header: bibcores.pls 120.2 2006/04/03 05:21:25 akbansal noship $ */
type myrctype is ref cursor;
type obj_uvs is table of BISM_OBJECTS.USER_VISIBLE%TYPE;
type obj_ids is table of BISM_OBJECTS.OBJECT_ID%TYPE;
type obj_otids is table of BISM_OBJECTS.OBJECT_TYPE_ID%TYPE;

function get_next_element(str varchar2,delimiter varchar2,startpos in out nocopy integer) return varchar2;
function get_last_object_id(fid raw,path varchar2,startpos in out nocopy integer,myid raw) return raw;
procedure delete_folder(fid raw,myid raw);
procedure delete_folder(fid raw,path varchar2,myid raw);
procedure delete_object(fid raw,objname varchar2,myid raw);
procedure set_privilege(fid raw,grantor raw,grantee_name varchar2,priv number);
procedure delete_folder_wo_security(fid raw,myid raw);
function prepare_rebind(fid raw,oname varchar2,myid raw,ids out nocopy bism_object_ids, current_time out nocopy date,num number,status out nocopy integer) return raw;
function prepare_rebind_30(fid raw,oname varchar2,myid raw,ids out nocopy raw, current_time out nocopy date,num number,status out nocopy integer) return raw;
function get_attributes(p_fid raw, p_objname varchar2, p_myid raw) return myrctype;
function check_modify_attrs_access(fid raw,objname varchar2,myid raw,status out nocopy number,callerid number) return varchar2;
function check_get_attrs_access(fid raw,objname varchar2,myid raw) return varchar2;
function check_user_privileges(p_username varchar2, p_oid raw, p_myid raw) return number;
function entries(p_oid in raw,p_myid in raw) return myrctype;
function add_entries(fid in raw,acllist in out nocopy  bism_acl_obj_t,myid in raw,cascade in varchar2,topfolder in varchar2) return bism_acl_obj_t;
procedure add_entries_30(fid in raw,acllist in CLOB,myid in raw,cascade in varchar2,topfolder in varchar2, aclseparator in varchar2);
function remove_entries(fid in raw,acllist in out nocopy  bism_acl_obj_t,myid in raw,cascade in varchar2,topfolder in varchar2) return bism_chararray_t;
function remove_entries_30(fid in raw,acllist in out nocopy CLOB,myid in raw,cascade in varchar2,topfolder in varchar2, aclseparator in varchar2) return varchar2;
function is_src_ancestor_of_target(srcfid raw,tgtfid raw) return boolean;
procedure move(srcfid raw,tgtfid raw,objname varchar2,myid raw);
procedure move_folder(topfolderid raw,tgtfid raw,objname varchar2, srcfid raw,myid raw);
procedure move_object(srcfid raw,tgtfid raw,objname varchar2,objid raw,myid raw);
function can_copy_folder(srcfid raw,tgtfid raw,myid raw) return boolean;
procedure copy_folder(srcfid raw,tgtfid raw,destobjname varchar2,myid raw,copytype integer,first_level boolean);
procedure copy(srcfid raw,tgtfid raw,srcobjname varchar2,destobjname varchar2,myid raw,copytype integer);
procedure copy_object(srcfid raw,tgtfid raw,srcobjname varchar2,destobjname varchar2,myid raw,copytype integer);
procedure copy_next_level(oldparentid raw,newparentid raw,tgtfid raw,myid raw,dummycounter in out nocopy integer,copytype integer);
procedure lookuphelper(fid raw,path bism_lookup_info_in_50_a,lookup_output out nocopy bism_lookup_info_out_50_a,myid raw);
procedure lookuphelper(fid raw,path varchar2, objname out nocopy varchar2,objid out nocopy raw,typeid out nocopy number, myid raw);
procedure lookup(fid raw,path bism_lookup_info_in_50_a,lookup_output in out nocopy bism_lookup_info_out_50_a,idx in out nocopy integer,myid raw);
procedure lookup(fid raw,path varchar2,a_objname out nocopy varchar2,a_objid out nocopy raw,a_typeid out nocopy number,myid raw,startpos in out nocopy integer) ;
function check_access_super_tree(startoid raw,stopoid raw,myid raw) return varchar2;
function get_object_full_name(oid raw) return varchar2;
function object_load (objid raw,myid raw) return myrctype;
function check_lookup_access(oid raw,fid raw,objtype number,visible varchar2,myid raw) return varchar2;
function get_folder(oid raw, myid raw) return myrctype;
function get_object(objid raw, myid raw, traceLastLoaded varchar2) return myrctype;
function fetch_objectsSQL1(cid raw, objid raw, myid raw) return myrctype;
function fetch_objectsSQL2(cid raw, myid raw, traceLastLoaded varchar2) return myrctype;
function rename_object(fid raw, objname varchar2, myid raw, callerid number, newobjname varchar2) return number;
function list(p_fid bism_objects.FOLDER_ID%type, p_subid bism_subjects.SUBJECT_ID%type) return myrctype;

/* Added due to refactoring (ccchow) */
function init(p_subname in bism_subjects.subject_name%type) return bism_subjects.SUBJECT_ID%type;
function create_subcontext(p_tempTimeC bism_objects.time_date_created%type,
                           p_tempTimeM bism_objects.time_date_modified%type,
                           p_creator bism_subjects.subject_name%type,
                           p_modifier bism_subjects.subject_name%type,
                           p_fid bism_objects.folder_id%type,
                           p_subid bism_subjects.subject_id%type,
                           p_version bism_objects.VERSION%type,
                           p_object_name bism_objects.object_name%type,
                           p_title bism_objects.title%type,
                           p_application bism_objects.application%type,
                           p_database bism_objects.database%type,
                           p_desc bism_objects.description%type,
                           p_keywords bism_objects.keywords%type,
                           p_appsubtype1 bism_objects.application_subtype1%type,
                           p_compsubtype1 bism_objects.COMP_SUBTYPE1%type,
                           p_compsubtype2 bism_objects.COMP_SUBTYPE2%type,
                           p_compsubtype3 bism_objects.COMP_SUBTYPE3%type) return bism_objects.object_id%type;
procedure bind(p_creator bism_subjects.SUBJECT_NAME%type,
               p_modifier bism_subjects.SUBJECT_NAME%type,
               p_subject_id bism_subjects.SUBJECT_ID%type,
               p_visible bism_objects.USER_VISIBLE%type,
               p_obj_type_id bism_objects.OBJECT_TYPE_ID%type,
               p_version bism_objects.VERSION%type,
               p_time_created bism_objects.TIME_DATE_CREATED%type,
               p_time_modified bism_objects.TIME_DATE_MODIFIED%type,
               p_oid bism_objects.OBJECT_ID%type,
               p_container_id bism_objects.CONTAINER_ID%type,
               p_fid bism_objects.FOLDER_ID%type,
               p_obj_name bism_objects.OBJECT_NAME%type,
               p_title bism_objects.TITLE%type,
               p_application bism_objects.APPLICATION%type,
               p_database bism_objects.DATABASE%type,
               p_desc bism_objects.DESCRIPTION%type,
               p_keywords bism_objects.KEYWORDS%type,
               p_xml bism_objects.XML%type,
               p_appsubtype1 bism_objects.APPLICATION_SUBTYPE1%type,
               p_compsubtype1 bism_objects.COMP_SUBTYPE1%type,
               p_compsubtype2 bism_objects.COMP_SUBTYPE2%type,
               p_compsubtype3 bism_objects.COMP_SUBTYPE3%type,
               p_container_id2 bism_aggregates.CONTAINER_ID%type,
               p_aggregate_info bism_aggregates.AGGREGATE_INFO%type);
procedure bind(p_creator bism_subjects.SUBJECT_NAME%type,
               p_modifier bism_subjects.SUBJECT_NAME%type,
               p_subject_id bism_subjects.SUBJECT_ID%type,
               p_visible bism_objects.USER_VISIBLE%type,
               p_obj_type_id bism_objects.OBJECT_TYPE_ID%type,
               p_version bism_objects.VERSION%type,
               p_time_created bism_objects.TIME_DATE_CREATED%type,
               p_time_modified bism_objects.TIME_DATE_MODIFIED%type,
               p_oid bism_objects.OBJECT_ID%type,
               p_container_id bism_objects.CONTAINER_ID%type,
               p_fid bism_objects.FOLDER_ID%type,
               p_obj_name bism_objects.OBJECT_NAME%type,
               p_title bism_objects.TITLE%type,
               p_application bism_objects.APPLICATION%type,
               p_database bism_objects.DATABASE%type,
               p_desc bism_objects.DESCRIPTION%type,
               p_keywords bism_objects.KEYWORDS%type,
               p_xml bism_objects.XML%type,
               p_appsubtype1 bism_objects.APPLICATION_SUBTYPE1%type,
               p_compsubtype1 bism_objects.COMP_SUBTYPE1%type,
               p_compsubtype2 bism_objects.COMP_SUBTYPE2%type,
               p_compsubtype3 bism_objects.COMP_SUBTYPE3%type,
               p_container_id2 bism_aggregates.CONTAINER_ID%type,
               p_aggregate_info bism_aggregates.AGGREGATE_INFO%type,
               p_ext_attrs_clob CLOB,
               p_time_last_loaded bism_objects.TIME_DATE_LAST_ACCESSED%type);
procedure bind_aggregate(p_container_id bism_aggregates.CONTAINER_ID%type,p_containee_id bism_aggregates.CONTAINEE_ID%type,p_aggregate_info bism_aggregates.AGGREGATE_INFO%type);
function list_bindings(p_fid bism_objects.FOLDER_ID%type,p_subid bism_subjects.SUBJECT_ID%type) return myrctype;
procedure rebind(p_creator bism_subjects.SUBJECT_NAME%type,
                 p_modifier bism_subjects.SUBJECT_NAME%type,
                 p_subject_id bism_subjects.SUBJECT_ID%type,
                 p_visible bism_objects.USER_VISIBLE%type,
                 p_obj_type_id bism_objects.OBJECT_TYPE_ID%type,
                 p_version bism_objects.VERSION%type,
                 p_time_created bism_objects.TIME_DATE_CREATED%type,
                 p_time_modified bism_objects.TIME_DATE_MODIFIED%type,
                 p_oid bism_objects.OBJECT_ID%type,
                 p_container_id bism_objects.CONTAINER_ID%type,
                 p_fid bism_objects.FOLDER_ID%type,
                 p_obj_name bism_objects.OBJECT_NAME%type,
                 p_title bism_objects.TITLE%type,
                 p_application bism_objects.APPLICATION%type,
                 p_database bism_objects.DATABASE%type,
                 p_desc bism_objects.DESCRIPTION%type,
                 p_keywords bism_objects.KEYWORDS%type,
                 p_xml bism_objects.XML%type,
                 p_appsubtype1 bism_objects.APPLICATION_SUBTYPE1%type,
                 p_compsubtype1 bism_objects.COMP_SUBTYPE1%type,
                 p_compsubtype2 bism_objects.COMP_SUBTYPE2%type,
                 p_compsubtype3 bism_objects.COMP_SUBTYPE3%type);
procedure rebind(p_creator bism_subjects.SUBJECT_NAME%type,
                 p_modifier bism_subjects.SUBJECT_NAME%type,
                 p_subject_id bism_subjects.SUBJECT_ID%type,
                 p_visible bism_objects.USER_VISIBLE%type,
                 p_obj_type_id bism_objects.OBJECT_TYPE_ID%type,
                 p_version bism_objects.VERSION%type,
                 p_time_created bism_objects.TIME_DATE_CREATED%type,
                 p_time_modified bism_objects.TIME_DATE_MODIFIED%type,
                 p_oid bism_objects.OBJECT_ID%type,
                 p_container_id bism_objects.CONTAINER_ID%type,
                 p_fid bism_objects.FOLDER_ID%type,
                 p_obj_name bism_objects.OBJECT_NAME%type,
                 p_title bism_objects.TITLE%type,
                 p_application bism_objects.APPLICATION%type,
                 p_database bism_objects.DATABASE%type,
                 p_desc bism_objects.DESCRIPTION%type,
                 p_keywords bism_objects.KEYWORDS%type,
                 p_xml bism_objects.XML%type,
                 p_appsubtype1 bism_objects.APPLICATION_SUBTYPE1%type,
                 p_compsubtype1 bism_objects.COMP_SUBTYPE1%type,
                 p_compsubtype2 bism_objects.COMP_SUBTYPE2%type,
                 p_compsubtype3 bism_objects.COMP_SUBTYPE3%type,
                 p_ext_attrs_clob CLOB,
                 p_time_last_loaded bism_objects.TIME_DATE_LAST_ACCESSED%type,
                 p_aggregate_info bism_aggregates.AGGREGATE_INFO%type,
                 p_obj_is_top_level varchar2);
/* new methods for object level security */
function add_entries(oid in raw,acllist in out nocopy bism_acl_obj_t,myid in raw,cascade_to_subfolders in varchar2,cascade_to_objs in varchar2,topfolder in varchar2,isfolder in varchar2) return bism_acl_obj_t;
procedure add_entries_30(oid in raw,acllist in CLOB,myid in raw,cascade_to_subfolders in varchar2,cascade_to_objs in varchar2,topfolder in varchar2,isfolder in varchar2, aclseparator in varchar2);
function remove_entries(oid in raw,acllist in out nocopy bism_acl_obj_t,myid in raw,cascade_to_subfolders in varchar2,cascade_to_objs in varchar2,topfolder in varchar2,isfolder in varchar2) return bism_chararray_t;
function remove_entries_30(oid in raw,acllist in out nocopy CLOB,myid in raw,cascade_to_subfolders in varchar2,cascade_to_objs in varchar2,topfolder in varchar2,isfolder in varchar2, aclseparator in varchar2) return varchar2;
function set_entries(oid in raw,acllist in out nocopy bism_acl_obj_t,myid in raw,cascade_to_subfolders in varchar2,cascade_to_objs in varchar2,topfolder in varchar2,isfolder in varchar2) return bism_acl_obj_t;
procedure set_entries_30(oid in raw,acllist in out nocopy CLOB,myid in raw,cascade_to_subfolders in varchar2,cascade_to_objs in varchar2,topfolder in varchar2,isfolder in varchar2, aclseparator in varchar2);
function check_lookup_access(oid raw,objtype number,visible varchar2,myid raw) return varchar2;
function check_del_access_for_folder(fid raw,myid raw) return varchar2;
function check_obj_del_access(oid raw,fid raw,myid raw) return varchar2;
function get_privilege(oid raw, myid raw) return number;
function prepare_rebind(fid raw,folder_path varchar2,oname varchar2,myid raw,ids out nocopy bism_object_ids, current_time out nocopy date,num number,status out nocopy integer,parentid out nocopy raw) return raw;
function prepare_rebind_30(fid raw,folder_path varchar2,oname varchar2,myid raw,ids out nocopy raw, current_time out nocopy date,num number,status out nocopy integer,parentid out nocopy raw) return raw;
procedure lookup_folder_wo_security(fid raw,path varchar2,a_objid out nocopy raw,myid raw,startpos in out nocopy integer);
function create_subcontext_30(p_tempTimeC bism_objects.time_date_created%type,
                              p_tempTimeM bism_objects.time_date_modified%type,
                              p_oid bism_objects.object_id%type,
                              p_creator bism_subjects.subject_name%type,
                              p_modifier bism_subjects.subject_name%type,
                              p_fid bism_objects.folder_id%type,
                              p_subid bism_subjects.subject_id%type,
                              p_version bism_objects.VERSION%type,
                              p_object_name bism_objects.object_name%type,
                              p_title bism_objects.title%type,
                              p_application bism_objects.application%type,
                              p_database bism_objects.database%type,
                              p_desc bism_objects.description%type,
                              p_keywords bism_objects.keywords%type,
                              p_appsubtype1 bism_objects.application_subtype1%type,
                              p_compsubtype1 bism_objects.COMP_SUBTYPE1%type,
                              p_compsubtype2 bism_objects.COMP_SUBTYPE2%type,
                              p_compsubtype3 bism_objects.COMP_SUBTYPE3%type,
                              p_extAttrs_clob CLOB) return bism_objects.object_id%type;

function list_dependents(p_fid bism_objects.FOLDER_ID%type, p_objname varchar2, p_myid raw) return myrctype;
procedure update_attribute(a_fid raw,a_obj_name varchar2,a_attr_name varchar2, a_attr_val varchar2, a_sub_id raw);
procedure update_date_attribute(a_fid raw,a_obj_name varchar2,a_attr_name varchar2, a_attr_val date, a_sub_id raw);
procedure update_attribute(a_fid raw,a_obj_name varchar2,a_ext_attr_xml varchar2, a_sub_id raw);
procedure set_auto_commit(p_val varchar2);
v_auto_commit BOOLEAN := TRUE;

CURSOR obj_ids_cursor(cid raw,myid raw) IS
SELECT T.USER_VISIBLE, T.OBJECT_TYPE_ID, T.OBJECT_ID
    from
	(
	SELECT A.USER_VISIBLE, A.OBJECT_TYPE_ID, A.OBJECT_ID
    from bism_objects A,
    (
    /* 3. distinct is required because there may be diamond relationships in the hierarchy
    and if so, we only want to fetch it once */
    /* 4. container_id = '30' is important because an object may have multiple containers
    in which case we end up fetching those rows as well, which is useless
    */
    select distinct containee_id,container_id,aggregate_info from bism_aggregates start with containee_id = cid and container_id='30' connect by container_id = prior containee_id
    )
    T1
    /* 5. fetch only the required object hierarchy */
    where A.object_id=T1.containee_id
    )
    T
    /* 6. the foll. security check is not needed, because lookuphelper the function that was
    called before this stmt gets executed has indeed checked for lookup_access
    but dropping this check does not seem to improve perf. so I am leaving it in
    for now */
    where
    'y' = bism_core.check_lookup_access(T.object_id, T.object_type_id, T.USER_VISIBLE, myid);

end  bism_core;

 

/
