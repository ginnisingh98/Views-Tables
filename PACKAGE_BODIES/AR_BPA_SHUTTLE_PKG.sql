--------------------------------------------------------
--  DDL for Package Body AR_BPA_SHUTTLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_SHUTTLE_PKG" as
/* $Header: ARBPSHLB.pls 120.1 2004/12/03 01:45:21 orashid noship $ */
procedure UPDATE_ITEM_MAP (
  P_TEMPLATE_ID in NUMBER,
  P_AREA_CODE in VARCHAR2,
  P_NEW_PARENT_AREA_CODE in VARCHAR2,
  P_SECONDARY_APP_ID in NUMBER default null,
  P_DISPLAY_LEVEL in VARCHAR2 default null,
  P_ITEM_ID in NUMBER default null,
  P_DISPLAY_SEQUENCE in NUMBER default null,
  P_DML_OPERATION IN VARCHAR2,
  X_STATUS out nocopy varchar2
) is
       l_user_id number := -1;
begin

	  IF (p_dml_operation = 'UPDATE') THEN
		  	update AR_BPA_AREA_ITEMS
		  	set DISPLAY_SEQUENCE 		= P_DISPLAY_SEQUENCE,
			    PARENT_AREA_CODE = P_NEW_PARENT_AREA_CODE,
					 LAST_UPDATE_DATE 	= sysdate,
					 LAST_UPDATED_BY 	= l_user_id,
					 LAST_UPDATE_LOGIN 	= l_user_id
		    where TEMPLATE_ID 			= P_TEMPLATE_ID
		    and   PARENT_AREA_CODE   			= P_AREA_CODE
		    AND   ITEM_ID          	= P_ITEM_ID;

			  if (sql%notfound) then
				  insert into AR_BPA_AREA_ITEMS (
				    AREA_ITEM_ID,
				    TEMPLATE_ID,
				    PARENT_AREA_CODE,
				    SECONDARY_APP_ID,
				  	DISPLAY_LEVEL ,
				  	item_id,
				  	display_sequence,
				    data_source_id,
				    flexfield_item_flag,
				    CREATED_BY,
				    CREATION_DATE,
				    LAST_UPDATED_BY,
				    LAST_UPDATE_DATE,
				    LAST_UPDATE_LOGIN
				  ) SELECT
				    ar_bpa_area_items_s.nextval,
				    P_TEMPLATE_ID,
				    P_AREA_CODE,
				    P_SECONDARY_APP_ID,
				  	P_DISPLAY_LEVEL ,
				  	P_ITEM_ID,
				  	P_DISPLAY_SEQUENCE,
				   	item.data_source_id,
					item.flexfield_item_flag,
				  	l_user_id,
				  	sysdate,
				  	l_user_id,
				  	sysdate,
				  	l_user_id
				  from ar_bpa_items_b item
				  where item.item_id = p_item_id;
			  end if;
		ELSIF (p_dml_operation = 'DELETE') THEN
				DELETE FROM AR_BPA_AREA_ITEMS
		    where TEMPLATE_ID 				= P_TEMPLATE_ID
		    and   PARENT_AREA_CODE   	= P_AREA_CODE
		    AND   ITEM_ID          		= decode(P_ITEM_ID,0,item_id,P_ITEM_ID);
	  END IF;

		x_status := 0;
EXCEPTION
	WHEN OTHERS THEN
		   x_status := -1;
end UPDATE_ITEM_MAP;

procedure UPDATE_ITEM_MAP_ARRAY (
  P_TEMPLATE_ID in NUMBER,
  P_AREA_CODE in VARCHAR2,
  P_NEW_PARENT_AREA_CODE in VARCHAR2,
  P_SECONDARY_APP_ID in NUMBER default null,
  P_DISPLAY_LEVEL in VARCHAR2 default null,
  P_ITEM_ID_LIST in item_varray,
  P_DISPLAY_SEQUENCE in NUMBER default null,
  P_DML_OPERATION IN VARCHAR2,
  X_STATUS out nocopy varchar2
) is
       l_user_id number := -1;
CURSOR c_existing_items IS
SELECT
	ITEM_ID
FROM 	ar_bpa_area_items
where   template_id = P_TEMPLATE_ID
AND     parent_area_code = P_AREA_CODE;

  l_translate_flag varchar2(1) := 'N';
  found boolean := false;
begin

        ar_bpa_utils_pkg.debug ('ar_bpa_shuttle_pkg.update_item_map_array(+)' );
	ar_bpa_utils_pkg.debug ('----Program Input-----');
	ar_bpa_utils_pkg.debug ('----   p_dml_operation   : '||p_dml_operation);
	ar_bpa_utils_pkg.debug ('----   p_template_id     : '||to_char(p_template_id));
	ar_bpa_utils_pkg.debug ('----   p_area_code       : '||p_area_code);
	ar_bpa_utils_pkg.debug ('----   p_new_parent_code : '||p_new_parent_area_code);
	ar_bpa_utils_pkg.debug ('----   p_secondary_app_id (not used): '||to_char(p_secondary_app_id));
	ar_bpa_utils_pkg.debug ('----   p_display_level   : '||p_display_level);
	ar_bpa_utils_pkg.debug ('----   p_display_sequence: '||to_char(p_display_sequence));
	ar_bpa_utils_pkg.debug ('----------------------------------------------------------------');

		FOR i IN 1..p_item_id_list.count
		LOOP
			ar_bpa_utils_pkg.debug ('Input item list: i= '||to_char(i)||', item id = '||p_item_id_list(i));
		end loop;


	  IF (p_dml_operation = 'UPDATE') THEN
		/* Delete items that have been removed in template mgmt */
		FOR crec IN c_existing_items
		LOOP
			found := false;

			for i in 1..p_item_id_list.count
			loop
				if crec.item_id = to_number(p_item_id_list(i))
				then
					found := true;
				end if;
			end loop;

			if (found = false)
			then
				DELETE FROM AR_BPA_AREA_ITEMS
				where TEMPLATE_ID 		= P_TEMPLATE_ID
				and   PARENT_AREA_CODE   	= P_AREA_CODE
				AND   ITEM_ID          	= crec.item_id;
			end if;
		END LOOP; -- crec

		FOR i IN 1..p_item_id_list.count
		LOOP
		  	update AR_BPA_AREA_ITEMS
		  	set DISPLAY_SEQUENCE 		= i,
			    PARENT_AREA_CODE = P_NEW_PARENT_AREA_CODE,
					 LAST_UPDATE_DATE 	= sysdate,
					 LAST_UPDATED_BY 	= l_user_id,
					 LAST_UPDATE_LOGIN 	= l_user_id
		    	where TEMPLATE_ID 			= P_TEMPLATE_ID
		    	and   PARENT_AREA_CODE   			= P_AREA_CODE
		    	AND   ITEM_ID          	= to_number(p_item_id_list(i));

			  if (sql%notfound) then
				  insert into AR_BPA_AREA_ITEMS (
				    AREA_ITEM_ID,
				    TEMPLATE_ID,
				    PARENT_AREA_CODE,
				    SECONDARY_APP_ID,
				  	DISPLAY_LEVEL ,
				  	item_id,
				  	display_sequence,
				    data_source_id,
				    flexfield_item_flag,
				    CREATED_BY,
				    CREATION_DATE,
				    LAST_UPDATED_BY,
				    LAST_UPDATE_DATE,
				    LAST_UPDATE_LOGIN
				  ) SELECT
				    ar_bpa_area_items_s.nextval,
				    P_TEMPLATE_ID,
				    P_AREA_CODE,
				    P_SECONDARY_APP_ID,
				  	P_DISPLAY_LEVEL ,
				  	to_number(p_item_id_list(i)),
				  	i,
				   	item.data_source_id,
					item.flexfield_item_flag,
				  	l_user_id,
				  	sysdate,
				  	l_user_id,
				  	sysdate,
				  	l_user_id
				  from ar_bpa_items_b item
				  where item.item_id = to_number(p_item_id_list(i));
				  ar_bpa_utils_pkg.debug ('i= '||to_char(i)||', item id = '||p_item_id_list(i)||' Inserted.');
			  else
				ar_bpa_utils_pkg.debug ('i= '||to_char(i)||', item id = '||p_item_id_list(i)||' Updated.');
			  end if;
	END LOOP; -- p_item_id_list
	END IF;

	IF (p_dml_operation = 'DELETE') THEN
		FOR i IN 1..p_item_id_list.count
		LOOP
			DELETE FROM AR_BPA_AREA_ITEMS
			where TEMPLATE_ID 	= P_TEMPLATE_ID
			and   PARENT_AREA_CODE  = P_AREA_CODE
			AND   ITEM_ID          	= to_number(p_item_id_list(i));
		        ar_bpa_utils_pkg.debug ('i= '||to_char(i)||', item id = '||p_item_id_list(i)||' Deleted.');
		END LOOP;
	END IF; -- delete

	x_status := 0;
EXCEPTION
	WHEN OTHERS THEN
		   x_status := -1;
		   ar_bpa_utils_pkg.debug ('update_item_map_array EXCEPTION: sqlerrm=['||sqlerrm||']');
end UPDATE_ITEM_MAP_ARRAY;

end AR_BPA_SHUTTLE_PKG;

/
