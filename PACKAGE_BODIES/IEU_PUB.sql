--------------------------------------------------------
--  DDL for Package Body IEU_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_PUB" AS
/* $Header: IEU_PB.pls 120.0 2005/06/02 15:49:55 appldev noship $ */

l_not_valid_flag	VARCHAR2(1);
l_not_valid		VARCHAR2(1);

/* Used to determine if agent is eligible for ANY media */
FUNCTION IS_AGENT_ELIGIBLE_FOR_MEDIA( P_RESOURCE_ID IN NUMBER )
  RETURN BOOLEAN
  AS

BEGIN

  RETURN IEU_PVT.IS_AGENT_ELIGIBLE_FOR_MEDIA( P_RESOURCE_ID );

END IS_AGENT_ELIGIBLE_FOR_MEDIA;


/* Used to determine if a connection to the UWQ server is required */
FUNCTION IS_UWQ_SERVER_REQUIRED( P_RESOURCE_ID IN NUMBER )
  RETURN BOOLEAN
  AS

BEGIN

  RETURN IEU_PVT.IS_UWQ_SERVER_REQUIRED( P_RESOURCE_ID );

END IS_UWQ_SERVER_REQUIRED;



FUNCTION SET_BIND_VAR_DATA( P_BindDataList IN BindVariableRecordList)
  RETURN VARCHAR2 IS

  bindString Varchar2(4000);

BEGIN

  for i in P_BindDataList.first .. P_BindDataList.Last
  loop

     bindString := bindString ||'<'||P_BindDataList(i).bind_var_name
                              ||'|'||P_BindDataList(i).bind_var_value
                              ||'|'||P_BindDataList(i).bind_var_data_type||'>';

  end loop;

  return bindString;
END;

FUNCTION GET_ENUM_RES_CAT(P_SEL_ENUM_ID IN NUMBER)
 RETURN VARCHAR2 IS

  l_def_where              VARCHAR2(20000);
  l_default_res_cat_id     NUMBER;
  l_profile_res_cat_id     NUMBER;

BEGIN

      BEGIN
        Select
          default_res_cat_id
        into
          l_default_res_cat_id
        from
          ieu_uwq_sel_enumerators
        where
          sel_enum_id = p_sel_enum_id;
    EXCEPTION
        when no_data_found then
         l_def_where := '';
    END;

    --dbms_output.put_line('l_Profile_res_cat_id'||l_profile_res_cat_id);
	BEGIN
	  Select where_clause
	  into	 l_def_where
	  from 	 ieu_uwq_res_cats_b
	  where	 res_cat_id = l_default_res_cat_id;
	EXCEPTION
	  when   NO_DATA_FOUND then null;
	END;

   RETURN l_def_where;

END get_enum_res_cat;

PROCEDURE ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID             IN NUMBER,
   P_SEL_ENUM_ID             IN NUMBER,
   P_ENUMERATOR_DATAREC_LIST IN IEU_PUB.EnumeratorDataRecordList
  ) AS

BEGIN

  IEU_PVT.ADD_UWQ_NODE_DATA(
    p_resource_id,
    p_sel_enum_id,
    p_enumerator_datarec_list );

END ADD_UWQ_NODE_DATA;

PROCEDURE GET_UWQ_NODE_DETAILS
   (P_RESOURCE_ID		IN NUMBER,
    P_NODE_ID 			IN NUMBER,
    X_NODE_DETAIL_RECORD        OUT NOCOPY IEU_PUB.NodeDetailRecord) IS

  l_where_clause         varchar2(4000);
  l_node_type            IEU_UWQ_SEL_RT_NODES.NODE_TYPE%TYPE;
  l_res_cat_enum_flag    IEU_UWQ_SEL_RT_NODES.RES_CAT_ENUM_FLAG%TYPE;
  l_extra_where_clause   IEU_UWQ_SEL_RT_NODES.WHERE_CLAUSE%TYPE;
  l_sel_rt_node_id       IEU_UWQ_SEL_RT_NODES.SEL_RT_NODE_ID%TYPE;
  l_sel_enum_id          IEU_UWQ_SEL_RT_NODES.SEL_ENUM_ID%TYPE;
  L_RES_CAT_WHERE_CLAUSE IEU_UWQ_RES_CATS_B.WHERE_CLAUSE%TYPE;
  L_RTNODE_BIND_VAR_FLAG VARCHAR2(10);
  L_ENUM_BIND_VAR_FLAG   VARCHAR2(10);


  CURSOR c_bindVal(l_node_id in NUMBER) IS
    SELECT
      rt_nodes_bind_val.SEL_RT_NODE_ID,
      rt_nodes_bind_val.node_id,
      rt_nodes_bind_val.bind_var_name,
      rt_nodes_bind_val.bind_var_value
    FROM
      ieu_uwq_rtnode_bind_vals rt_nodes_bind_val
    WHERE
      (rt_nodes_bind_val.resource_id = p_resource_id) AND
      (rt_nodes_bind_val.node_id = l_node_id) AND
      (rt_nodes_bind_val.not_valid_flag = l_not_valid_flag);
BEGIN
  l_not_valid_flag := 'N';
  l_not_valid	   := 'N';

  BEGIN
     Select where_clause,
	 node_type,
         refresh_view_name,
         refresh_view_sum_col,
         view_name,
         sel_enum_id,
         sel_rt_node_id,
         res_cat_enum_flag
     into   l_extra_where_clause,
	 l_node_type,
         X_NODE_DETAIL_RECORD.REFRESH_VIEW_NAME,
         X_NODE_DETAIL_RECORD.refresh_view_sum_col,
         X_NODE_DETAIL_RECORD.view_name,
         l_sel_enum_id,
         l_sel_rt_node_id,
         l_res_cat_enum_flag
     from   ieu_uwq_sel_rt_nodes
     where  resource_id = p_resource_id
     and    node_id = p_node_id
     and   not_valid = l_not_valid;
  EXCEPTION when no_data_found THEN
     null;
  END;


  if ( (p_node_id = IEU_CONSTS_PUB.G_SNID_MEDIA) or
       (p_node_id = IEU_CONSTS_PUB.G_SNID_BLENDED) )
  then
        begin
          select
            where_clause
          into
            l_res_cat_where_clause
          from
            ieu_uwq_res_cats_b
          where
            res_cat_id = 10001;

        exception
          when no_data_found then
            null;
        end;
   else
        l_res_cat_where_clause := ieu_pub.get_enum_res_cat(l_sel_enum_id);
   end if;

   -- Set the complete Where Clause

   if (l_extra_where_clause is NULL)
   then
        l_where_clause := l_res_cat_where_clause;
        l_rtnode_bind_var_flag := 'F';
   else

        if (l_res_cat_enum_flag = 'Y') OR (l_res_cat_enum_flag is NULL)
        then
          if  (l_res_cat_where_clause) is not null
          then
            l_where_clause :=
              l_res_cat_where_clause || ' and ' || l_extra_where_clause;
              l_rtnode_bind_var_flag := 'F';
          end if;
        else
          l_where_clause := l_extra_where_clause;
          l_rtnode_bind_var_flag := 'T';
        end if;
   end if;

   select
        decode(
          (instr(l_res_cat_where_clause, ':resource_id', 1, 1)), 0, 'F','T' )
   into
        l_enum_bind_var_flag
   from
        dual;

   If (l_rtnode_bind_var_flag = 'T')
   then


       for b in c_bindVal(p_node_id)
       loop

          if ( (b.sel_rt_node_id = l_sel_rt_node_id) and
               (b.node_id   = p_node_id) )
          then
              SELECT REPLACE(l_where_clause,b.bind_var_name,b.bind_var_value)
              INTO   l_where_clause
              FROM   DUAL;

	      -- Set the Bind variables for Runtime Where Clause
              SELECT REPLACE(l_extra_where_clause,b.bind_var_name,b.bind_var_value)
              INTO   l_extra_where_clause
              FROM   DUAL;


          end if;

       end loop;


    else

       if (l_enum_bind_var_flag = 'T')
       then
              SELECT REPLACE(l_where_clause,':resource_id',p_resource_id)
              INTO   l_where_clause
              FROM   DUAL;
       end if;

    end if;

    X_NODE_DETAIL_RECORD.NODE_TYPE    := l_node_type;
    X_NODE_DETAIL_RECORD.COMPLETE_WHERE_CLAUSE := l_where_clause;
    X_NODE_DETAIL_RECORD.NODE_RUNTIME_WHERE_CLAUSE := l_extra_where_clause;

END;

PROCEDURE GET_UWQ_NODE_DETAILS
   (P_RESOURCE_ID		IN NUMBER,
    P_NODE_ID 			IN NUMBER,
    X_NODE_DETAIL_RECORD        OUT NOCOPY IEU_PUB.NodeDetailRecord,
    X_BIND_VARIABLE_RECORD_LIST OUT NOCOPY IEU_PUB.BindVariableRecordList) IS

  l_where_clause         varchar2(4000);
  l_node_type            IEU_UWQ_SEL_RT_NODES.NODE_TYPE%TYPE;
  l_res_cat_enum_flag    IEU_UWQ_SEL_RT_NODES.RES_CAT_ENUM_FLAG%TYPE;
  l_extra_where_clause   IEU_UWQ_SEL_RT_NODES.WHERE_CLAUSE%TYPE;
  l_sel_rt_node_id       IEU_UWQ_SEL_RT_NODES.SEL_RT_NODE_ID%TYPE;
  l_sel_enum_id          IEU_UWQ_SEL_RT_NODES.SEL_ENUM_ID%TYPE;
  L_RES_CAT_WHERE_CLAUSE IEU_UWQ_RES_CATS_B.WHERE_CLAUSE%TYPE;
  L_RTNODE_BIND_VAR_FLAG VARCHAR2(10);
  L_ENUM_BIND_VAR_FLAG   VARCHAR2(10);
  l_rec_count            NUMBER;


  CURSOR c_bindVal(l_node_id in NUMBER) IS
    SELECT
      rt_nodes_bind_val.SEL_RT_NODE_ID,
      rt_nodes_bind_val.node_id,
      rt_nodes_bind_val.bind_var_name,
      rt_nodes_bind_val.bind_var_value,
      rt_nodes_bind_val.bind_var_datatype
    FROM
      ieu_uwq_rtnode_bind_vals rt_nodes_bind_val
    WHERE
      (rt_nodes_bind_val.resource_id = p_resource_id) AND
      (rt_nodes_bind_val.node_id = l_node_id) AND
      (rt_nodes_bind_val.not_valid_flag = l_not_valid_flag);

BEGIN
  l_not_valid_flag := 'N';
  l_not_valid	   := 'N';

  BEGIN
     Select where_clause,
	 node_type,
         refresh_view_name,
         refresh_view_sum_col,
         view_name,
         sel_enum_id,
         sel_rt_node_id,
         res_cat_enum_flag
     into   l_extra_where_clause,
	 l_node_type,
         X_NODE_DETAIL_RECORD.REFRESH_VIEW_NAME,
         X_NODE_DETAIL_RECORD.refresh_view_sum_col,
         X_NODE_DETAIL_RECORD.view_name,
         l_sel_enum_id,
         l_sel_rt_node_id,
         l_res_cat_enum_flag
     from   ieu_uwq_sel_rt_nodes
     where  resource_id = p_resource_id
     and    node_id = p_node_id
     and   not_valid = l_not_valid;
  EXCEPTION when no_data_found THEN
     null;
  END;


  if ( (p_node_id = IEU_CONSTS_PUB.G_SNID_MEDIA) or
       (p_node_id = IEU_CONSTS_PUB.G_SNID_BLENDED) )
  then
        begin
          select
            where_clause
          into
            l_res_cat_where_clause
          from
            ieu_uwq_res_cats_b
          where
            res_cat_id = 10001;

        exception
          when no_data_found then
            null;
        end;
   else
        l_res_cat_where_clause := ieu_pub.get_enum_res_cat(l_sel_enum_id);
   end if;

   -- Set the complete Where Clause

   if (l_extra_where_clause is NULL)
   then
        l_where_clause := l_res_cat_where_clause;
        l_rtnode_bind_var_flag := 'F';
   else

        if (l_res_cat_enum_flag = 'Y') OR (l_res_cat_enum_flag is NULL)
        then
          if  (l_res_cat_where_clause) is not null
          then
            l_where_clause :=
              l_res_cat_where_clause || ' and ' || l_extra_where_clause;
              l_rtnode_bind_var_flag := 'F';
          end if;
        else
          l_where_clause := l_extra_where_clause;
          l_rtnode_bind_var_flag := 'T';
        end if;
   end if;

   X_NODE_DETAIL_RECORD.RAW_COMPLETE_WHERE_CLAUSE := l_where_clause;
   X_NODE_DETAIL_RECORD.RAW_NODE_RUNTIME_WHERE_CLAUSE := l_extra_where_clause;

   select
        decode(
          (instr(l_res_cat_where_clause, ':resource_id', 1, 1)), 0, 'F','T' )
   into
        l_enum_bind_var_flag
   from
        dual;

   If (l_rtnode_bind_var_flag = 'T')
   then

       l_rec_count := 0;
       for b in c_bindVal(p_node_id)
       loop

          if ( (b.sel_rt_node_id = l_sel_rt_node_id) and
               (b.node_id   = p_node_id) )
          then
              SELECT REPLACE(l_where_clause,b.bind_var_name,b.bind_var_value)
              INTO   l_where_clause
              FROM   DUAL;

	      -- Set the Bind variables for Runtime Where Clause
              SELECT REPLACE(l_extra_where_clause,b.bind_var_name,b.bind_var_value)
              INTO   l_extra_where_clause
              FROM   DUAL;

              l_rec_count := l_rec_count + 1;
              X_BIND_VARIABLE_RECORD_LIST(l_rec_count).BIND_VAR_NAME := b.bind_var_name;
              X_BIND_VARIABLE_RECORD_LIST(l_rec_count).BIND_VAR_VALUE := b.bind_var_value;
              X_BIND_VARIABLE_RECORD_LIST(l_rec_count).BIND_VAR_DATA_TYPE := b.bind_var_datatype;
          end if;

       end loop;


    else

       if (l_enum_bind_var_flag = 'T')
       then
              SELECT REPLACE(l_where_clause,':resource_id',p_resource_id)
              INTO   l_where_clause
              FROM   DUAL;
       end if;

    end if;

    X_NODE_DETAIL_RECORD.NODE_TYPE    := l_node_type;
    X_NODE_DETAIL_RECORD.COMPLETE_WHERE_CLAUSE := l_where_clause;
    X_NODE_DETAIL_RECORD.NODE_RUNTIME_WHERE_CLAUSE := l_extra_where_clause;

END;
END IEU_PUB;

/
