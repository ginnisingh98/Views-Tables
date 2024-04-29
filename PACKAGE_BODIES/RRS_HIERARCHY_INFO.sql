--------------------------------------------------------
--  DDL for Package Body RRS_HIERARCHY_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_HIERARCHY_INFO" as
/* $Header: RRSGHDTB.pls 120.1.12010000.5 2009/10/13 22:38:16 jijiao noship $ */
------------------------
--Get Hierarchy Header--
------------------------

Procedure Get_Hierarchy_Header(
	p_api_version			IN		number
       ,p_hier_version_id		IN		number
       ,x_hier_header_rec		OUT NOCOPY	rrs_hier_header_rec
       ,x_return_status                 OUT NOCOPY	varchar2
       ,x_msg_count                     OUT NOCOPY	number
       ,x_msg_data                      OUT NOCOPY	varchar2
) is

BEGIN
    IF x_msg_count IS NULL THEN
    	x_msg_count := 0;
    END IF;

    SELECT rrs_hier_header_rec(
    	   RSGB.SITE_GROUP_ID,
    	   RSGB.SITE_GROUP_TYPE_CODE,
           RSGT.NAME,
           RSGB.GROUP_PURPOSE_CODE,
           LKUP.MEANING,
           RSGT.DESCRIPTION,
           RSGB.START_DATE,
           RSGB.END_DATE)
      INTO x_hier_header_rec
      FROM RRS_SITE_GROUP_VERSIONS RSGV, RRS_SITE_GROUPS_B RSGB, RRS_SITE_GROUPS_TL RSGT, RRS_LOOKUPS_V LKUP
     WHERE RSGT.LANGUAGE = userenv('LANG')
       AND RSGV.SITE_GROUP_VERSION_ID = p_hier_version_id
       AND RSGB.SITE_GROUP_ID = RSGV.SITE_GROUP_ID
       AND RSGT.SITE_GROUP_ID = RSGB.SITE_GROUP_ID
       AND 'RRS_HIERARCHY_PURPOSE' = LKUP.LOOKUP_TYPE(+)
       AND RSGB.GROUP_PURPOSE_CODE  = LKUP.LOOKUP_CODE(+);

    x_return_status := G_RET_STS_SUCCESS;

EXCEPTION
	WHEN OTHERS THEN
		x_msg_data := 'RRS_HIERARCHY_INFO.Get_Hierarchy_Header: ' || dbms_utility.format_error_backtrace;
		fnd_message.set_name('RRS', 'RRS_UNEXPECTED_ERROR');
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_UNEXP_ERROR;
END;


Procedure Get_Hierarchy_Header(
	p_api_version			IN		number
       ,p_hier_id			IN		number
       ,p_hier_version_number		IN		number
       ,x_hier_header_rec		OUT NOCOPY	rrs_hier_header_rec
       ,x_return_status                 OUT NOCOPY	varchar2
       ,x_msg_count                     OUT NOCOPY	number
       ,x_msg_data                      OUT NOCOPY	varchar2
) is

l_hier_version_number	number;
l_hier_version_id	number;

BEGIN
	IF x_msg_count IS NULL THEN
		x_msg_count := 0;
	END IF;

	l_hier_version_number := p_hier_version_number;

	--if user does not provide version number, api will pick up the latest version number
	IF l_hier_version_number IS NULL THEN
		SELECT MAX(VERSION_NUMBER)
		  INTO l_hier_version_number
		  FROM RRS_SITE_GROUP_VERSIONS
		 WHERE SITE_GROUP_ID = p_hier_id;
	END IF;

	SELECT SITE_GROUP_VERSION_ID
	  INTO l_hier_version_id
	  FROM RRS_SITE_GROUP_VERSIONS
	 WHERE SITE_GROUP_ID = p_hier_id
	   AND VERSION_NUMBER = l_hier_version_number;

	Get_Hierarchy_Header(p_api_version	=> p_api_version
			    ,p_hier_version_id	=> l_hier_version_id
			    ,x_hier_header_rec	=> x_hier_header_rec
			    ,x_return_status	=> x_return_status
			    ,x_msg_count	=> x_msg_count
			    ,x_msg_data		=> x_msg_data);
EXCEPTION
	WHEN OTHERS THEN
		x_msg_data := 'RRS_HIERARCHY_INFO.Get_Hierarchy_Header: ' || dbms_utility.format_error_backtrace;
		fnd_message.set_name('RRS', 'RRS_UNEXPECTED_ERROR');
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_UNEXP_ERROR;
END;



Procedure Get_Hierarchy_Header(
	p_api_version              	IN         	number
       ,p_hier_name			IN		varchar2
       ,x_hier_header_rec		OUT NOCOPY	rrs_hier_header_rec
       ,x_return_status                 OUT NOCOPY	varchar2
       ,x_msg_count                     OUT NOCOPY	number
       ,x_msg_data                      OUT NOCOPY	varchar2
) is

l_hier_id	number;

--need lookup site group purpose meaning
BEGIN
	IF x_msg_count IS NULL THEN
		x_msg_count := 0;
	END IF;

    	SELECT SITE_GROUP_ID
    	  INTO l_hier_id
    	  FROM RRS_SITE_GROUPS_VL
    	 WHERE NAME = p_hier_name;

	Get_Hierarchy_Header(p_api_version		=> p_api_version
			    ,p_hier_id			=> l_hier_id
			    ,p_hier_version_number	=> NULL
			    ,x_hier_header_rec		=> x_hier_header_rec
			    ,x_return_status		=> x_return_status
			    ,x_msg_count		=> x_msg_count
			    ,x_msg_data			=> x_msg_data);


EXCEPTION
	WHEN NO_DATA_FOUND THEN
		fnd_message.set_name('RRS', 'RRS_NO_HIER_FOUND');
		fnd_message.set_token('HIERARCHY_NAME', p_hier_name);
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_ERROR;
	WHEN OTHERS THEN
		x_msg_data := 'RRS_HIERARCHY_INFO.Get_Hierarchy_Header: ' || dbms_utility.format_error_backtrace;
		fnd_message.set_name('RRS', 'RRS_UNEXPECTED_ERROR');
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_UNEXP_ERROR;
END;


-------------------------
--Get Hierarchy Members--
-------------------------

-- For bug fix 9011360
-- Add SiteGroupId condition to the main SQL query, because the SiteGroupId is the first index column.  This will fix the performance issue.
-- jijiao 10/13/2009
Procedure Get_Hierarchy_Members(
	p_api_version			IN		number
       ,p_hier_version_id		IN		number
       ,p_parent_member_type		IN		varchar2
       ,p_parent_member_id_num		IN		varchar2
       ,x_hier_members_tab		OUT NOCOPY	rrs_hier_members_tab
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
) is

l_site_group_id 	rrs_site_groups_b.site_group_id%TYPE;
l_site_group_version_id rrs_site_group_versions.site_group_version_id%TYPE;
l_parent_id 		rrs_site_group_members.parent_member_id%TYPE;

x_hier_header_rec 	rrs_hier_header_rec;


BEGIN
	   IF x_msg_count IS NULL THEN
		   x_msg_count := 0;
	   END IF;

	   -- query the site group id from version id
	   -- For Bug Fix 9011360  - jijiao 10/13/2009
	   SELECT SITE_GROUP_ID
	     INTO l_site_group_id
	     FROM RRS_SITE_GROUP_VERSIONS
	    WHERE SITE_GROUP_VERSION_ID = p_hier_version_id;


	   --query the members in the whole hierarchy
	   --parent is the root so parent id is -1
	   IF p_parent_member_type IS NULL AND p_parent_member_id_num IS NULL THEN
		l_parent_id := -1;

	   --query a sub-hierarchy under the speicific parent
	   --query the parent id according to the parent identification number input
	   ELSIF p_parent_member_type IS NOT NULL AND p_parent_member_id_num IS NOT NULL THEN
		BEGIN
			IF UPPER(p_parent_member_type) = 'SITE' THEN
			   SELECT SITE_ID
			     INTO l_parent_id
			     FROM RRS_SITES_B
			    WHERE SITE_IDENTIFICATION_NUMBER = p_parent_member_id_num;
			ELSIF UPPER(p_parent_member_type) = 'NODE' THEN
			   SELECT SITE_GROUP_NODE_ID
			     INTO l_parent_id
			     FROM RRS_SITE_GROUP_NODES_B
			    WHERE NODE_IDENTIFICATION_NUMBER = p_parent_member_id_num;
			END IF;

			IF l_parent_id IS NULL THEN
				fnd_message.set_name('RRS', 'RRS_HIER_NO_PARENT_MBR_FOUND');
				fnd_message.set_token('PARENT_TYPE', p_parent_member_type);
				fnd_message.set_token('PARENT_ID_NUM', p_parent_member_id_num);
				fnd_message.set_token('HIERARCHY_NAME', p_hier_version_id);
				fnd_msg_pub.add;
				x_msg_count := x_msg_count + 1;
				x_return_status := G_RET_STS_ERROR;
			END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				fnd_message.set_name('RRS', 'RRS_HIER_NO_PARENT_MBR_FOUND');
				fnd_message.set_token('PARENT_TYPE', p_parent_member_type);
				fnd_message.set_token('PARENT_ID_NUM', p_parent_member_id_num);
				fnd_message.set_token('HIERARCHY_NAME', p_hier_version_id);
				fnd_msg_pub.add;
				x_msg_count := x_msg_count + 1;
				x_return_status := G_RET_STS_ERROR;
		END;
	   ELSE
		fnd_message.set_name('RRS', 'RRS_MISS_PARENT_TYPE_OR_ID_NUM');
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_ERROR;
	   END IF;

	   -- For bug fix 9011360
	   -- Add SiteGroupId condition to the main SQL query, because the SiteGroupId is the first index column.  This will fix the performance issue.
	   -- jijiao 10/13/2009
	   IF l_parent_id IS NOT NULL THEN
		SELECT rrs_hier_members_rec(
		       SiteGroupMembers.SITE_GROUP_ID,
		       SiteGroupMembers.SITE_GROUP_VERSION_ID,
		       DECODE(SiteGroupMembers.PARENT_MEMBER_ID, -1, NULL, DECODE(SiteGroupNodes2.SITE_GROUP_NODE_ID, NULL, Sites2.SITE_ID,
			      SiteGroupNodes2.SITE_GROUP_NODE_ID)),
		       DECODE(SiteGroupMembers.PARENT_MEMBER_ID, -1, NULL, DECODE(SiteGroupNodes2.SITE_GROUP_NODE_ID, NULL, Sites2.SITE_IDENTIFICATION_NUMBER,
			      SiteGroupNodes2.NODE_IDENTIFICATION_NUMBER)),
		       DECODE(SiteGroupMembers.PARENT_MEMBER_ID, -1, NULL, DECODE(SiteGroupNodes2.NAME, NULL, Sites2.NAME,SiteGroupNodes2.NAME)),
		       DECODE(SiteGroupMembers.PARENT_MEMBER_ID, -1, NULL, DECODE(SiteGroupNodes2.SITE_GROUP_NODE_ID, NULL, 'SITE', 'NODE')),
		       DECODE(SiteGroupMembers.PARENT_MEMBER_ID, -1, NULL,
			     DECODE(SiteGroupNodes2.SITE_GROUP_NODE_ID, NULL,
				      (SELECT LKUP.MEANING
					 FROM RRS_SITE_USES RSU, AR_LOOKUPS LKUP
					WHERE RSU.SITE_ID = SiteGroupMembers.PARENT_MEMBER_ID AND RSU.IS_PRIMARY_FLAG = 'Y' AND LKUP.LOOKUP_TYPE = 'PARTY_SITE_USE_CODE' AND RSU.SITE_USE_TYPE_CODE = LKUP.LOOKUP_CODE),
				      (SELECT LKUP.MEANING
					 FROM RRS_SITE_GROUP_NODES_B RSGNB, RRS_LOOKUPS_V LKUP
					WHERE RSGNB.SITE_GROUP_NODE_ID = SiteGroupMembers.PARENT_MEMBER_ID AND LKUP.LOOKUP_TYPE = 'RRS_NODE_PURPOSE' AND RSGNB.NODE_PURPOSE_CODE = LKUP.LOOKUP_CODE))),
		       DECODE(SiteGroupMembers.PARENT_MEMBER_ID, -1, 'Y', 'N'),
		       DECODE(SiteGroupNodes1.SITE_GROUP_NODE_ID, NULL, Sites1.SITE_ID,
			      SiteGroupNodes1.SITE_GROUP_NODE_ID),
		       DECODE(SiteGroupNodes1.SITE_GROUP_NODE_ID, NULL, Sites1.SITE_IDENTIFICATION_NUMBER,
			      SiteGroupNodes1.NODE_IDENTIFICATION_NUMBER),
		       DECODE(SiteGroupNodes1.NAME, NULL, Sites1.NAME, SiteGroupNodes1.NAME),
		       DECODE(SiteGroupNodes1.SITE_GROUP_NODE_ID, NULL, 'SITE', 'NODE'),
		       DECODE(SiteGroupNodes1.SITE_GROUP_NODE_ID, NULL,
			     (SELECT SITE_USE_TYPE_CODE FROM RRS_SITE_USES WHERE RRS_SITE_USES.SITE_ID = SiteGroupMembers.CHILD_MEMBER_ID AND RRS_SITE_USES.IS_PRIMARY_FLAG = 'Y'),
			     (SELECT NODE_PURPOSE_CODE FROM RRS_SITE_GROUP_NODES_B RSGNB WHERE RSGNB.SITE_GROUP_NODE_ID = SiteGroupMembers.CHILD_MEMBER_ID)),
		       DECODE(SiteGroupNodes1.SITE_GROUP_NODE_ID, NULL,
			     (SELECT LKUP.MEANING
				FROM RRS_SITE_USES, AR_LOOKUPS LKUP
			       WHERE RRS_SITE_USES.SITE_ID = SiteGroupMembers.CHILD_MEMBER_ID AND RRS_SITE_USES.IS_PRIMARY_FLAG = 'Y' AND LKUP.LOOKUP_TYPE = 'PARTY_SITE_USE_CODE' AND RRS_SITE_USES.SITE_USE_TYPE_CODE = LKUP.LOOKUP_CODE),
			     (SELECT LKUP.MEANING
				FROM RRS_SITE_GROUP_NODES_B RSGNB, RRS_LOOKUPS_V LKUP
			       WHERE RSGNB.SITE_GROUP_NODE_ID = SiteGroupMembers.CHILD_MEMBER_ID AND RSGNB.NODE_PURPOSE_CODE = LKUP.LOOKUP_CODE AND LKUP.LOOKUP_TYPE = 'RRS_NODE_PURPOSE')),
		       DECODE(SiteGroupNodes1.SITE_GROUP_NODE_ID, NULL, Sites1.DESCRIPTION, SiteGroupNodes1.DESCRIPTION),
		       DECODE(SiteGroupNodes1.SITE_GROUP_NODE_ID, NULL, Sites1.SITE_STATUS_CODE, NULL),
		       DECODE(SiteGroupNodes1.SITE_GROUP_NODE_ID, NULL, (SELECT MEANING FROM RRS_LOOKUPS_V WHERE LOOKUP_TYPE = 'RRS_SITE_STATUS' AND LOOKUP_CODE = Sites1.SITE_STATUS_CODE), NULL),
		       SiteGroupMembers.SEQUENCE_NUMBER,
		       LEVEL
		       )
		  BULK COLLECT
		  INTO x_hier_members_tab
		  FROM RRS_SITE_GROUP_MEMBERS SiteGroupMembers,
		       RRS_SITE_GROUP_NODES_VL SiteGroupNodes1,
		       RRS_SITE_GROUP_NODES_VL SiteGroupNodes2,
		       RRS_SITES_VL Sites1,
		       RRS_SITES_VL Sites2
		 WHERE SiteGroupMembers.CHILD_MEMBER_ID = SiteGroupNodes1.SITE_GROUP_NODE_ID(+)
		   AND SiteGroupMembers.CHILD_MEMBER_ID = Sites1.SITE_ID(+)
		   AND SiteGroupMembers.PARENT_MEMBER_ID = SiteGroupNodes2.SITE_GROUP_NODE_ID(+)
		   AND SiteGroupMembers.PARENT_MEMBER_ID = Sites2.SITE_ID(+)
		   AND SiteGroupMembers.DELETED_FLAG = 'N'
	    START WITH PARENT_MEMBER_ID = l_parent_id AND SiteGroupMembers.SITE_GROUP_ID = l_site_group_id AND SiteGroupMembers.SITE_GROUP_VERSION_ID = p_hier_version_id
	CONNECT BY PRIOR CHILD_MEMBER_ID = PARENT_MEMBER_ID AND SiteGroupMembers.SITE_GROUP_ID = l_site_group_id AND SiteGroupMembers.SITE_GROUP_VERSION_ID = p_hier_version_id
	ORDER SIBLINGS BY SEQUENCE_NUMBER;

		IF x_hier_members_tab IS NULL OR x_hier_members_tab.count = 0 THEN
			fnd_message.set_name('RRS', 'RRS_HIER_NO_CHILD_MBR_FOUND');
			fnd_msg_pub.add;
			x_msg_count := x_msg_count + 1;
			x_return_status := G_RET_STS_ERROR;
		END IF;

	   END IF;

	IF x_msg_count = 0 THEN
		x_return_status := G_RET_STS_SUCCESS;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		x_msg_data := 'RRS_HIERARCHY_INFO.Get_Hierarchy_Members: ' || dbms_utility.format_error_backtrace;
		fnd_message.set_name('RRS', 'RRS_UNEXPECTED_ERROR');
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_UNEXP_ERROR;

END;



Procedure Get_Hierarchy_Members(
	p_api_version			IN		number
       ,p_hier_id			IN		number
       ,p_hier_version_number		IN		number
       ,p_parent_member_type		IN		varchar2
       ,p_parent_member_id_num		IN		varchar2
       ,x_hier_members_tab		OUT NOCOPY	rrs_hier_members_tab
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
) is

l_hier_version_id		number;
l_parent_id			number;
l_parent_member_type		varchar2(100);
l_parent_member_id_number	varchar2(100);

BEGIN
	IF x_msg_count IS NULL THEN
	   x_msg_count := 0;
	END IF;

	/* get site_group_version_id
	   if user does not provide version number, we return the latest version*/

	SELECT SITE_GROUP_VERSION_ID
	  INTO l_hier_version_id
	  FROM RRS_SITE_GROUP_VERSIONS
	 WHERE SITE_GROUP_ID = p_hier_id
	   AND VERSION_NUMBER = DECODE(p_hier_version_number, NULL, (SELECT MAX(VERSION_NUMBER)
								       FROM RRS_SITE_GROUP_VERSIONS
								      WHERE SITE_GROUP_ID = p_hier_id),
								    p_hier_version_number);


	   --query a sub-hierarchy under the speicific parent
	   --query the parent id according to the parent identification number input
	   IF p_parent_member_type IS NOT NULL AND p_parent_member_id_num IS NOT NULL THEN
		BEGIN
			IF UPPER(p_parent_member_type) = 'SITE' THEN
			   SELECT SITE_ID
			     INTO l_parent_id
			     FROM RRS_SITES_B
			    WHERE SITE_IDENTIFICATION_NUMBER = p_parent_member_id_num;
			ELSIF UPPER(p_parent_member_type) = 'NODE' THEN
			   SELECT SITE_GROUP_NODE_ID
			     INTO l_parent_id
			     FROM RRS_SITE_GROUP_NODES_B
			    WHERE NODE_IDENTIFICATION_NUMBER = p_parent_member_id_num;
			END IF;

			IF l_parent_id IS NULL THEN
				RAISE e_no_parent_member_found;
			END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RAISE e_no_parent_member_found;
		END;
	   END IF;


	Get_Hierarchy_Members(p_api_version		=> p_api_version
			     ,p_hier_version_id		=> l_hier_version_id
			     ,p_parent_member_type 	=> p_parent_member_type
			     ,p_parent_member_id_num	=> p_parent_member_id_num
			     ,x_hier_members_tab	=> x_hier_members_tab
			     ,x_return_status		=> x_return_status
			     ,x_msg_count		=> x_msg_count
			     ,x_msg_data		=> x_msg_data);

EXCEPTION
	WHEN e_no_parent_member_found THEN
		fnd_message.set_name('RRS', 'RRS_HIER_NO_PARENT_MBR_FOUND');
		fnd_message.set_token('PARENT_TYPE', p_parent_member_type);
		fnd_message.set_token('PARENT_ID_NUM', p_parent_member_id_num);
		fnd_message.set_token('HIERARCHY_NAME', p_hier_id);
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_ERROR;

	WHEN OTHERS THEN
		x_msg_data := 'RRS_HIERARCHY_INFO.Get_Hierarchy_Members: ' || dbms_utility.format_error_backtrace;
		fnd_message.set_name('RRS', 'RRS_UNEXPECTED_ERROR');
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_UNEXP_ERROR;

END;


Procedure Get_Hierarchy_Members(
	p_api_version			IN		number
       ,p_hier_name			IN		varchar2
       ,p_hier_version_number		IN		number
       ,p_parent_member_type		IN		varchar2
       ,p_parent_member_id_num		IN		varchar2
       ,x_hier_members_tab		OUT NOCOPY	rrs_hier_members_tab
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
) is

l_hier_id		number;
l_parent_id 		rrs_site_group_members.parent_member_id%TYPE;

BEGIN
	IF x_msg_count IS NULL THEN
	    	x_msg_count := 0;
    	END IF;

	/* get site_group_id from hier name*/
	BEGIN
		SELECT SITE_GROUP_ID
		  INTO l_hier_id
		  FROM RRS_SITE_GROUPS_VL
		 WHERE NAME = p_hier_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE e_no_hierarchy_found;
	END;

	   --query a sub-hierarchy under the speicific parent
	   --query the parent id according to the parent identification number input
	   IF p_parent_member_type IS NOT NULL AND p_parent_member_id_num IS NOT NULL THEN
	   	BEGIN
			IF UPPER(p_parent_member_type) = 'SITE' THEN
			   SELECT SITE_ID
			     INTO l_parent_id
			     FROM RRS_SITES_B
			    WHERE SITE_IDENTIFICATION_NUMBER = p_parent_member_id_num;
			ELSIF UPPER(p_parent_member_type) = 'NODE' THEN
			   SELECT SITE_GROUP_NODE_ID
			     INTO l_parent_id
			     FROM RRS_SITE_GROUP_NODES_B
			    WHERE NODE_IDENTIFICATION_NUMBER = p_parent_member_id_num;
			END IF;

			IF l_parent_id IS NULL THEN
				RAISE e_no_parent_member_found;
			END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RAISE e_no_parent_member_found;
		END;
	   END IF;


	Get_Hierarchy_Members(p_api_version		=> p_api_version
			     ,p_hier_id			=> l_hier_id
			     ,p_hier_version_number	=> p_hier_version_number
			     ,p_parent_member_type 	=> p_parent_member_type
			     ,p_parent_member_id_num	=> p_parent_member_id_num
			     ,x_hier_members_tab	=> x_hier_members_tab
			     ,x_return_status		=> x_return_status
			     ,x_msg_count		=> x_msg_count
			     ,x_msg_data		=> x_msg_data);


EXCEPTION
	WHEN e_no_hierarchy_found THEN
		fnd_message.set_name('RRS', 'RRS_NO_HIER_FOUND');
		fnd_message.set_token('HIERARCHY_NAME', p_hier_name);
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_ERROR;
	WHEN e_no_parent_member_found THEN
		fnd_message.set_name('RRS', 'RRS_HIER_NO_PARENT_MBR_FOUND');
		fnd_message.set_token('PARENT_TYPE', p_parent_member_type);
		fnd_message.set_token('PARENT_ID_NUM', p_parent_member_id_num);
		fnd_message.set_token('HIERARCHY_NAME', p_hier_name);
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_ERROR;
	WHEN OTHERS THEN
		x_msg_data := 'RRS_HIERARCHY_INFO.Get_Hierarchy_Members: ' || dbms_utility.format_error_backtrace;
		fnd_message.set_name('RRS', 'RRS_UNEXPECTED_ERROR');
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_UNEXP_ERROR;

END;



----------------------------
--Get Hierarchy Attributes--
----------------------------

Procedure Get_Hierarchy_Attributes(
	p_api_version			IN		number
       ,p_hier_version_id		IN		number
       ,p_page_name			IN		varchar2
       ,x_hier_attr_row_tab		OUT NOCOPY	ego_user_attr_row_table
       ,x_hier_attr_data_tab		OUT NOCOPY	ego_user_attr_data_table
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
) is

l_api_name		CONSTANT VARCHAR2(30) := 'Get_Hierarchy_User_Attributes';
l_rrs_entity_name	rrs_lookups_v.meaning%Type;
l_pk_column_values	EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_object_name		VARCHAR2(30);
l_attr_group_type	VARCHAR2(30);
l_data_level_name 	VARCHAR2(30);
l_page_id 		NUMBER;
l_display_name		VARCHAR2(240);
l_request_table		EGO_ATTR_GROUP_REQUEST_TABLE;

l_site_group_id 	NUMBER;
l_group_purpose_code    VARCHAR2(30);


l_x_attributes_row_table   	EGO_USER_ATTR_ROW_TABLE;
l_x_attributes_data_table  	EGO_USER_ATTR_DATA_TABLE;
l_x_return_status          	VARCHAR2(1);
l_x_errorcode              	NUMBER;
l_x_msg_count              	NUMBER;
l_x_msg_data               	VARCHAR2(1000);

Type attr_grp_name_tab IS TABLE OF VARCHAR2(30);
l_attr_grp_names  attr_grp_name_Tab;

BEGIN
	IF x_msg_count IS NULL THEN
	    	x_msg_count := 0;
    	END IF;

	/* get site_group_id*/
	BEGIN
		SELECT RSG.SITE_GROUP_ID, RSG.GROUP_PURPOSE_CODE
		  INTO l_site_group_id, l_group_purpose_code
		  FROM RRS_SITE_GROUPS_VL RSG, RRS_SITE_GROUP_VERSIONS RSGV
		 WHERE RSG.SITE_GROUP_ID = RSGV.SITE_GROUP_ID
		   AND RSGV.SITE_GROUP_VERSION_ID = p_hier_version_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			fnd_message.set_name('RRS', 'RRS_NO_HIER_FOUND');
			fnd_message.set_token('HIERARCHY_NAME', p_hier_version_id);
			fnd_msg_pub.add;
			x_msg_count := x_msg_count + 1;
			x_return_status := G_RET_STS_ERROR;
	END;

	SELECT MEANING
	  INTO l_rrs_entity_name
	  FROM RRS_LOOKUPS_V
	 WHERE LOOKUP_TYPE = 'RRS_ENTITY'
	   AND LOOKUP_CODE = 'RRS_HIERARCHY';

	/* get attribute groups for the hierarchy and its classification code*/
	IF p_page_name IS NULL THEN

		SELECT ext.DESCRIPTIVE_FLEX_CONTEXT_CODE
		BULK COLLECT
		  INTO l_attr_grp_names
		  FROM EGO_OBJ_AG_ASSOCS_B eoab
		      ,FND_OBJECTS fo
		      ,EGO_FND_DSC_FLX_CTX_EXT ext
		 WHERE eoab.OBJECT_ID = fo.OBJECT_ID
		   AND fo.OBJ_NAME = 'RRS_HIERARCHY'
		   AND eoab.ATTR_GROUP_ID = ext.ATTR_GROUP_ID
		   AND eoab.CLASSIFICATION_CODE = l_group_purpose_code;

	ELSIF p_page_name IS NOT NULL THEN

		BEGIN
			SELECT PAGE_ID,
			       DISPLAY_NAME
			  INTO l_page_id,
			       l_display_name
			  FROM EGO_PAGES_V
			 WHERE OBJECT_NAME = 'RRS_HIERARCHY'
			   AND DISPLAY_NAME = p_page_name
			   AND CLASSIFICATION_CODE = l_group_purpose_code
			 ORDER BY SEQUENCE;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				fnd_message.set_name('RRS', 'RRS_NO_PAGE_FOUND');
				fnd_message.set_token('PAGE_NAME', p_page_name);
				fnd_message.set_token('CLASSIFICATION_CODE', l_group_purpose_code);
				fnd_msg_pub.add;
				x_msg_count := x_msg_count + 1;
				x_return_status := G_RET_STS_ERROR;
		END;

		BEGIN
			SELECT ATTR_GROUP_NAME
			BULK COLLECT
			  INTO l_attr_grp_names
			  FROM EGO_PAGE_ENTRIES_V
			 WHERE PAGE_ID = l_page_id
			 ORDER BY SEQUENCE;
		EXCEPTION

			WHEN NO_DATA_FOUND THEN
				fnd_message.set_name('RRS', 'RRS_NO_PAGE_ENTRY_FOUND');
				fnd_message.set_token('PAGE_NAME', p_page_name);
				fnd_msg_pub.add;
				x_msg_count := x_msg_count + 1;
				x_return_status := G_RET_STS_ERROR;
		END;

	END IF;

	l_pk_column_values := EGO_COL_NAME_VALUE_PAIR_ARRAY(
				EGO_COL_NAME_VALUE_PAIR_OBJ('SITE_GROUP_VERSION_ID', TO_CHAR(p_hier_version_id)));
	l_object_name := 'RRS_HIERARCHY';
	l_attr_group_type := 'RRS_HIERARCHY_GROUP';
	l_data_level_name := 'HIERARCHY_LEVEL';

	IF l_attr_grp_names IS NOT NULL AND l_attr_grp_names.COUNT > 0 THEN
		x_hier_attr_row_tab := new EGO_USER_ATTR_ROW_TABLE();
		x_hier_attr_data_tab := new EGO_USER_ATTR_DATA_TABLE();

		FOR i in l_attr_grp_names.FIRST .. l_attr_grp_names.LAST
		LOOP
			l_request_table := new EGO_ATTR_GROUP_REQUEST_TABLE();
			l_request_table.EXTEND();
			l_request_table(l_request_table.LAST) := new EGO_ATTR_GROUP_REQUEST_OBJ(
									 NULL			-- ATTR_GROUP_ID
									,718			-- APPLICATION_ID
									,l_attr_group_type	-- ATTR_GROUP_TYPE
									,l_attr_grp_names(i)	-- ATTR_GROUP_NAME
									,l_data_level_name	-- DATA_LEVEL
									,NULL			-- DATA_LEVEL_1
									,NULL			-- DATA_LEVEL_2
									,NULL			-- DATA_LEVEL_3
									,NULL			-- DATA_LEVEL_4
									,NULL			-- DATA_LEVEL_5
									,NULL			-- ATTR_NAME_LIST
								);
			/* call API to get attribute groups and attributes*/
			EGO_USER_ATTRS_DATA_PUB.Get_User_Attrs_Data(
				 p_api_version			=> 1.0
				,p_object_name			=> l_object_name
				,p_pk_column_name_value_pairs	=> l_pk_column_values
				,p_attr_group_request_table	=> l_request_table
				,p_user_privileges_on_object	=> NULL
				,p_entity_id			=> NULL
				,p_entity_index			=> NULL
				,p_entity_code			=> NULL
				,p_debug_level			=> 0
				,p_init_error_handler		=> FND_API.G_FALSE
				,p_init_fnd_msg_list		=> FND_API.G_FALSE
				,p_add_errors_to_fnd_stack	=> FND_API.G_FALSE
				,p_commit			=> FND_API.G_FALSE
				,x_attributes_row_table		=> l_x_attributes_row_table
				,x_attributes_data_table	=> l_x_attributes_data_table
				,x_return_status		=> l_x_return_status
				,x_errorcode			=> l_x_errorcode
				,x_msg_count			=> l_x_msg_count
				,x_msg_data			=> l_x_msg_data
			);

			/*Take the error messages returned from EGO API into our count*/
			IF l_x_msg_count IS NOT NULL THEN
				x_msg_count := x_msg_count + l_x_msg_count;
			END IF;


			IF l_x_attributes_row_table IS NOT NULL AND l_x_attributes_row_table.COUNT >0 AND
			   l_x_attributes_data_table IS NOT NULL AND l_x_attributes_data_table.COUNT > 0 THEN

				FOR n in l_x_attributes_row_table.FIRST .. l_x_attributes_row_table.LAST
				LOOP
					x_hier_attr_row_tab.EXTEND();
					x_hier_attr_row_tab(x_hier_attr_row_tab.LAST) := l_x_attributes_row_table(n);

				END LOOP;

				FOR n in l_x_attributes_data_table.FIRST .. l_x_attributes_data_table.LAST
				LOOP
					x_hier_attr_data_tab.EXTEND();
					x_hier_attr_data_tab(x_hier_attr_data_tab.LAST) := l_x_attributes_data_table(n);
				END LOOP;

			END IF;

		END LOOP;

	END IF;

	IF x_msg_count = 0 THEN
		x_return_status := G_RET_STS_SUCCESS;
	END IF;


EXCEPTION
	WHEN OTHERS THEN
		x_msg_data := 'RRS_HIERARCHY_INFO.Get_Hierarchy_Attributes: ' || dbms_utility.format_error_backtrace;
		fnd_message.set_name('RRS', 'RRS_UNEXPECTED_ERROR');
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_UNEXP_ERROR;

END;


Procedure Get_Hierarchy_Attributes(
	p_api_version			IN		number
       ,p_hier_id			IN		number
       ,p_hier_version_number		IN		number
       ,p_page_name			IN		varchar2
       ,x_hier_attr_row_tab		OUT NOCOPY	ego_user_attr_row_table
       ,x_hier_attr_data_tab		OUT NOCOPY	ego_user_attr_data_table
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
) is

l_hier_version_id	number;

BEGIN
	IF x_msg_count IS NULL THEN
	    	x_msg_count := 0;
    	END IF;

	/* get site_group_version_id
	   if user does not provide version number, we return the latest version*/

	SELECT SITE_GROUP_VERSION_ID
	  INTO l_hier_version_id
	  FROM RRS_SITE_GROUP_VERSIONS
	 WHERE SITE_GROUP_ID = p_hier_id
	   AND VERSION_NUMBER = DECODE(p_hier_version_number, NULL, (SELECT MAX(VERSION_NUMBER)
								       FROM RRS_SITE_GROUP_VERSIONS
								      WHERE SITE_GROUP_ID = p_hier_id),
								    p_hier_version_number);

	Get_Hierarchy_Attributes(p_api_version		=> p_api_version
				,p_hier_version_id	=> l_hier_version_id
				,p_page_name		=> p_page_name
				,x_hier_attr_row_tab	=> x_hier_attr_row_tab
				,x_hier_attr_data_tab	=> x_hier_attr_data_tab
				,x_return_status	=> x_return_status
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data);
EXCEPTION
	WHEN OTHERS THEN
		x_msg_data := 'RRS_HIERARCHY_INFO.Get_Hierarchy_Attributes: ' || dbms_utility.format_error_backtrace;
		fnd_message.set_name('RRS', 'RRS_UNEXPECTED_ERROR');
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_UNEXP_ERROR;
END;


Procedure Get_Hierarchy_Attributes(
	p_api_version			IN		number
       ,p_hier_name			IN		varchar2
       ,p_hier_version_number		IN		number
       ,p_page_name			IN		varchar2
       ,x_hier_attr_row_tab		OUT NOCOPY	ego_user_attr_row_table
       ,x_hier_attr_data_tab		OUT NOCOPY	ego_user_attr_data_table
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
) is

l_hier_id 	NUMBER;

BEGIN
	IF x_msg_count IS NULL THEN
	    	x_msg_count := 0;
    	END IF;
	-- get site_group_id
	BEGIN
		SELECT SITE_GROUP_ID
		  INTO l_hier_id
		  FROM RRS_SITE_GROUPS_VL
		 WHERE NAME = p_hier_name;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE e_no_hierarchy_found;
	END;

	Get_Hierarchy_Attributes(p_api_version		=> p_api_version
				,p_hier_id		=> l_hier_id
				,p_hier_version_number	=> p_hier_version_number
				,p_page_name		=> p_page_name
				,x_hier_attr_row_tab	=> x_hier_attr_row_tab
				,x_hier_attr_data_tab	=> x_hier_attr_data_tab
				,x_return_status	=> x_return_status
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data);

EXCEPTION
	WHEN e_no_hierarchy_found THEN
		fnd_message.set_name('RRS', 'RRS_NO_HIER_FOUND');
		fnd_message.set_token('HIERARCHY_NAME', p_hier_name);
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_ERROR;
	WHEN OTHERS THEN
		x_msg_data := 'RRS_HIERARCHY_INFO.Get_Hierarchy_Attributes: ' || dbms_utility.format_error_backtrace;
		fnd_message.set_name('RRS', 'RRS_UNEXPECTED_ERROR');
		fnd_msg_pub.add;
		x_msg_count := x_msg_count + 1;
		x_return_status := G_RET_STS_UNEXP_ERROR;

END;


----------------------------------
--Get Hierarchy Complete Details--
----------------------------------

Procedure Get_Complete_Hierarchy_Details(
	p_api_version			IN		number
       ,p_hier_version_id		IN		number
       ,p_page_name			IN		varchar2
       ,x_hier_header_rec		OUT NOCOPY	rrs_hier_header_rec
       ,x_hier_members_tab		OUT NOCOPY	rrs_hier_members_tab
       ,x_hier_attr_row_tab		OUT NOCOPY	ego_user_attr_row_table
       ,x_hier_attr_data_tab		OUT NOCOPY	ego_user_attr_data_table
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
) is

BEGIN

	Get_Hierarchy_Header(
		 p_api_version		=>		p_api_version
		,p_hier_version_id	=>		p_hier_version_id
		,x_hier_header_rec	=>		x_hier_header_rec
		,x_return_status	=> 		x_return_status
		,x_msg_count		=> 		x_msg_count
		,x_msg_data 		=> 		x_msg_data);

	Get_Hierarchy_Members(
		 p_api_version		=>		p_api_version
		,p_hier_version_id	=>		p_hier_version_id
		,p_parent_member_type	=>		NULL
		,p_parent_member_id_num	=>		NULL
		,x_hier_members_tab	=>		x_hier_members_tab
		,x_return_status	=> 		x_return_status
		,x_msg_count		=> 		x_msg_count
		,x_msg_data 		=> 		x_msg_data);

	Get_Hierarchy_Attributes(
		 p_api_version		=>		p_api_version
		,p_hier_version_id	=>		p_hier_version_id
		,p_page_name		=>		p_page_name
		,x_hier_attr_row_tab	=>		x_hier_attr_row_tab
		,x_hier_attr_data_tab	=>		x_hier_attr_data_tab
		,x_return_status	=> 		x_return_status
		,x_msg_count		=> 		x_msg_count
		,x_msg_data 		=> 		x_msg_data);

END;

Procedure Get_Complete_Hierarchy_Details(
	p_api_version			IN		number
       ,p_hier_id			IN		number
       ,p_hier_version_number		IN		number
       ,p_page_name			IN		varchar2
       ,x_hier_header_rec		OUT NOCOPY	rrs_hier_header_rec
       ,x_hier_members_tab		OUT NOCOPY	rrs_hier_members_tab
       ,x_hier_attr_row_tab		OUT NOCOPY	ego_user_attr_row_table
       ,x_hier_attr_data_tab		OUT NOCOPY	ego_user_attr_data_table
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
) is

BEGIN

	Get_Hierarchy_Header(
		 p_api_version		=>		p_api_version
		,p_hier_id		=>		p_hier_id
		,p_hier_version_number	=>		p_hier_version_number
		,x_hier_header_rec	=>		x_hier_header_rec
		,x_return_status	=> 		x_return_status
		,x_msg_count		=> 		x_msg_count
		,x_msg_data 		=> 		x_msg_data);

	Get_Hierarchy_Members(
		 p_api_version		=>		p_api_version
		,p_hier_id		=>		p_hier_id
       		,p_hier_version_number	=>		p_hier_version_number
		,p_parent_member_type	=>		NULL
		,p_parent_member_id_num	=>		NULL
		,x_hier_members_tab	=>		x_hier_members_tab
		,x_return_status	=> 		x_return_status
		,x_msg_count		=> 		x_msg_count
		,x_msg_data 		=> 		x_msg_data);

	Get_Hierarchy_Attributes(
		 p_api_version		=>		p_api_version
		,p_hier_id		=>		p_hier_id
		,p_hier_version_number	=>		p_hier_version_number
		,p_page_name		=>		p_page_name
		,x_hier_attr_row_tab	=>		x_hier_attr_row_tab
		,x_hier_attr_data_tab	=>		x_hier_attr_data_tab
		,x_return_status	=> 		x_return_status
		,x_msg_count		=> 		x_msg_count
		,x_msg_data 		=> 		x_msg_data);

END;


Procedure Get_Complete_Hierarchy_Details(
	p_api_version			IN		number
       ,p_hier_name			IN		varchar2
       ,p_hier_version_number		IN		number
       ,p_page_name			IN		varchar2
       ,x_hier_header_rec		OUT NOCOPY	rrs_hier_header_rec
       ,x_hier_members_tab		OUT NOCOPY	rrs_hier_members_tab
       ,x_hier_attr_row_tab		OUT NOCOPY	ego_user_attr_row_table
       ,x_hier_attr_data_tab		OUT NOCOPY	ego_user_attr_data_table
       ,x_return_status			OUT NOCOPY	varchar2
       ,x_msg_count			OUT NOCOPY	number
       ,x_msg_data			OUT NOCOPY	varchar2
) is

BEGIN

	Get_Hierarchy_Header(
		 p_api_version		=>		p_api_version
		,p_hier_name		=>		p_hier_name
		,x_hier_header_rec	=>		x_hier_header_rec
		,x_return_status	=> 		x_return_status
		,x_msg_count		=> 		x_msg_count
		,x_msg_data 		=> 		x_msg_data);

	Get_Hierarchy_Members(
		 p_api_version		=>		p_api_version
		,p_hier_name		=>		p_hier_name
       		,p_hier_version_number	=>		p_hier_version_number
		,p_parent_member_type	=>		NULL
		,p_parent_member_id_num	=>		NULL
		,x_hier_members_tab	=>		x_hier_members_tab
		,x_return_status	=> 		x_return_status
		,x_msg_count		=> 		x_msg_count
		,x_msg_data 		=> 		x_msg_data);

	Get_Hierarchy_Attributes(
		 p_api_version		=>		p_api_version
		,p_hier_name		=>		p_hier_name
		,p_hier_version_number	=>		p_hier_version_number
		,p_page_name		=>		p_page_name
		,x_hier_attr_row_tab	=>		x_hier_attr_row_tab
		,x_hier_attr_data_tab	=>		x_hier_attr_data_tab
		,x_return_status	=> 		x_return_status
		,x_msg_count		=> 		x_msg_count
		,x_msg_data 		=> 		x_msg_data);

END;



/**
 ** Test Methods (FOR DEBUGGING ONLY)
 **
 *
Procedure Get_Hierarchy_Header_Test
is

x_hier_header_rec rrs_hier_header_rec;
--x_error_msg varchar2(255);
x_return_status	varchar2(20);
x_error_msg_count number;
x_error_msg varchar2(200);

BEGIN

RRS_HIERARCHY_INFO.Get_Hierarchy_Header(p_api_version   =>	'1.0'
		    ,p_hier_name			=>	'Unit Hierarchy'
		    ,x_hier_header_rec			=>	x_hier_header_rec
		    ,x_return_status			=>	x_return_status
		    ,x_msg_count			=>	x_error_msg_count
       		    ,x_msg_data 			=>	x_error_msg);

   dbms_output.put_line(x_return_status);
   dbms_output.put_line(x_error_msg_count);
   dbms_output.put_line(x_error_msg);

   IF(x_hier_header_rec IS NOT NULL) THEN
	   dbms_output.put_line(chr(13) || chr(10));
	   dbms_output.put_line('Printing Hierarchy Header Information  ');
	   dbms_output.put_line('==============================  ');
	   dbms_output.put_line('Hierarchy ID: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.site_group_id);
	   dbms_output.put_line('Site Group Type Code: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.site_group_type_code);
	   dbms_output.put_line('Name: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.name);
	   dbms_output.put_line('Hierarchy Purpose Code: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.site_group_purpose_code);
	   dbms_output.put_line('Hierarchy Purpose: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.site_group_purpose);
	   dbms_output.put_line('Description: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.description);
	   dbms_output.put_line('Start Date: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.start_date);
	   dbms_output.put_line('End Date: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.end_date);

   END IF;
END;


Procedure Get_Hierarchy_Members_Test
is

x_hier_members_tab rrs_hier_members_tab;
x_return_status	varchar2(20);
x_error_msg_count number;
x_error_msg varchar2(200);

BEGIN
RRS_HIERARCHY_INFO.Get_Hierarchy_Members(
        p_api_version		=> '1.0'
       ,p_hier_name		=> 'WS Hierarchy1'
       ,p_hier_version_number	=>  NULL
       ,p_parent_member_type 	=> 'NODE'
       ,p_parent_member_id_num 	=> 'WS_NODE1'
       ,x_hier_members_tab 	=> x_hier_members_tab
       ,x_return_status		=> x_return_status
       ,x_msg_count		=> x_error_msg_count
       ,x_msg_data 		=> x_error_msg);

	--dbms_output.put_line(x_hier_members_tab.count);

	dbms_output.put_line(x_return_status);
	dbms_output.put_line(x_error_msg_count);
	dbms_output.put_line(x_error_msg);

	IF(x_error_msg_count < 1) THEN
		dbms_output.put_line(chr(13) || chr(10));
		dbms_output.put_line('Printing Hierarchy Members ');
		dbms_output.put_line('==============================  ');
		FOR i in x_hier_members_tab.FIRST..x_hier_members_tab.LAST LOOP
		    dbms_output.put_line('Site Group ID: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).site_group_id);
		    dbms_output.put_line('Site Group Version ID: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).site_group_version_id);
		    dbms_output.put_line('Parent ID: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).parent_id);
		    dbms_output.put_line('Parent Identification Number: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).parent_id_num);
		    dbms_output.put_line('Parent Name: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).parent_name);
		    dbms_output.put_line('Parent Type: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).parent_type);
		    dbms_output.put_line('Parent Purpose: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).parent_purpose);
		    dbms_output.put_line('Is Root: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).is_root);
		    dbms_output.put_line('Child ID: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).child_id);
		    dbms_output.put_line('Child Identification Number: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).child_id_num);
		    dbms_output.put_line('Child Name: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).child_name);
		    dbms_output.put_line('Child Type: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).child_type);
		    dbms_output.put_line('Child Purpose Code: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).child_purpose_code);
		    dbms_output.put_line('Child Purpose: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).child_purpose);
		    dbms_output.put_line('Description: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).description);
		    dbms_output.put_line('Status Code: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).status_code);
		    dbms_output.put_line('Status: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).status);
		    dbms_output.put_line('Child Sequence: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).child_sequence);
		    dbms_output.put_line('Depth: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).depth);
		    dbms_output.put_line('==============================  ');
		END LOOP;
	END IF;
END;



Procedure Get_Hierarchy_Attributes_Test
is

x_hier_attr_row_tab 	ego_user_attr_row_table;
x_hier_attr_data_tab	ego_user_attr_data_table;
x_return_status		varchar2(30);
x_error_msg_count	number;
x_error_msg		varchar2(200);

row_index		number;
data_index		number;

BEGIN

	RRS_HIERARCHY_INFO.Get_Hierarchy_Attributes(
		 p_api_version		=>	1.0
		,p_hier_name		=>	'Unit Hierarchy'
		,p_hier_version_number	=>	NULL
		,p_page_name		=>	'Hierarchy UDA Page Sample'
		,x_hier_attr_row_tab	=>	x_hier_attr_row_tab
		,x_hier_attr_data_tab	=>	x_hier_attr_data_tab
	        ,x_return_status	=> 	x_return_status
	        ,x_msg_count		=> 	x_error_msg_count
	        ,x_msg_data 		=> 	x_error_msg);

	dbms_output.put_line(x_return_status);
	dbms_output.put_line(x_error_msg_count);
	dbms_output.put_line(x_error_msg);

	IF x_hier_attr_row_tab IS NOT NULL AND x_hier_attr_row_tab.COUNT > 0 THEN
		FOR row_index in x_hier_attr_row_tab.FIRST .. x_hier_attr_row_tab.LAST
		LOOP
			DBMS_OUTPUT.PUT_LINE('===========================================');
			DBMS_OUTPUT.PUT_LINE('ROW ID: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_row_tab(row_index).ROW_IDENTIFIER);
			DBMS_OUTPUT.PUT_LINE('ATTR_GROUP_ID: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_row_tab(row_index).ATTR_GROUP_ID);
			DBMS_OUTPUT.PUT_LINE('ATTR_GROUP_APP_ID: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_row_tab(row_index).ATTR_GROUP_APP_ID);
			DBMS_OUTPUT.PUT_LINE('ATTR_GROUP_TYPE: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_row_tab(row_index).ATTR_GROUP_TYPE);
			DBMS_OUTPUT.PUT_LINE('ATTR_GROUP_NAME: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_row_tab(row_index).ATTR_GROUP_NAME);
			DBMS_OUTPUT.PUT_LINE('DATA_LEVEL: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_row_tab(row_index).DATA_LEVEL);

			IF x_hier_attr_data_tab IS NOT NULL AND x_hier_attr_data_tab.COUNT > 0 THEN
				FOR data_index in x_hier_attr_data_tab.FIRST .. x_hier_attr_data_tab.LAST
				LOOP
					IF x_hier_attr_data_tab(data_index).ROW_IDENTIFIER <> x_hier_attr_row_tab(row_index).ROW_IDENTIFIER THEN
						EXIT;
					END IF;

					DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
					DBMS_OUTPUT.PUT_LINE('ROW ID: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_data_tab(data_index).ROW_IDENTIFIER);
					DBMS_OUTPUT.PUT_LINE('ATTR_NAME: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_data_tab(data_index).ATTR_NAME);
					DBMS_OUTPUT.PUT_LINE('ATTR_VALUE_STR: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_data_tab(data_index).ATTR_VALUE_STR);
					DBMS_OUTPUT.PUT_LINE('ATTR_VALUE_NUM: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_data_tab(data_index).ATTR_VALUE_NUM);
					DBMS_OUTPUT.PUT_LINE('ATTR_VALUE_DATE: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_data_tab(data_index).ATTR_VALUE_DATE);
					DBMS_OUTPUT.PUT_LINE('ATTR_DISP_VALUE: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_data_tab(data_index).ATTR_DISP_VALUE);
					DBMS_OUTPUT.PUT_LINE('ATTR_UNIT_OF_MEASURE: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_data_tab(data_index).ATTR_UNIT_OF_MEASURE);

				END LOOP;
			END IF;
		END LOOP;
	END IF;


END;


Procedure Get_Comp_Hier_Details_Test
is

x_hier_header_rec rrs_hier_header_rec;
x_hier_members_tab rrs_hier_members_tab;
x_hier_attr_row_tab ego_user_attr_row_table;
x_hier_attr_data_tab ego_user_attr_data_table;
x_return_status	varchar2(20);
x_error_msg_count number;
x_error_msg varchar2(200);

BEGIN
RRS_HIERARCHY_INFO.Get_Complete_Hierarchy_Details(
	 p_api_version		=>		1.0
	,p_hier_name		=>		'Unit Hierarchy'
	,p_hier_version_number	=>		1
	,p_page_name		=>		NULL
	,x_hier_header_rec	=>		x_hier_header_rec
	,x_hier_members_tab	=>		x_hier_members_tab
	,x_hier_attr_row_tab	=>		x_hier_attr_row_tab
	,x_hier_attr_data_tab	=>		x_hier_attr_data_tab
        ,x_return_status	=> 		x_return_status
        ,x_msg_count		=> 		x_error_msg_count
        ,x_msg_data 		=> 		x_error_msg);

	dbms_output.put_line(x_return_status);
	dbms_output.put_line(x_error_msg_count);
	dbms_output.put_line(x_error_msg);


   IF(x_hier_header_rec IS NOT NULL) THEN
	   dbms_output.put_line(chr(13) || chr(10));
	   dbms_output.put_line('Printing Hierarchy Header Information  ');
	   dbms_output.put_line('==============================  ');
	   dbms_output.put_line('Hierarchy ID: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.site_group_id);
	   dbms_output.put_line('Site Group Type Code: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.site_group_type_code);
	   dbms_output.put_line('Name: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.name);
	   dbms_output.put_line('Hierarchy Purpose Code: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.site_group_purpose_code);
	   dbms_output.put_line('Hierarchy Purpose: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.site_group_purpose);
	   dbms_output.put_line('Description: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.description);
	   dbms_output.put_line('Start Date: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.start_date);
	   dbms_output.put_line('End Date: '||chr(9)||chr(9)||chr(9)|| x_hier_header_rec.end_date);

   END IF;

	dbms_output.put_line(x_return_status);


	IF(x_hier_members_tab IS NOT NULL AND x_hier_members_tab.COUNT > 0) THEN
		dbms_output.put_line(chr(13) || chr(10));
		dbms_output.put_line('Printing Hierarchy Members ');
		dbms_output.put_line('==============================  ');
		FOR i in x_hier_members_tab.FIRST..x_hier_members_tab.LAST LOOP
		    dbms_output.put_line('Site Group ID: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).site_group_id);
		    dbms_output.put_line('Site Group Version ID: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).site_group_version_id);
		    dbms_output.put_line('Parent ID: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).parent_id);
		    dbms_output.put_line('Parent Identification Number: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).parent_id_num);
		    dbms_output.put_line('Parent Name: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).parent_name);
		    dbms_output.put_line('Parent Type: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).parent_type);
		    dbms_output.put_line('Parent Purpose: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).parent_purpose);
		    dbms_output.put_line('Is Root: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).is_root);
		    dbms_output.put_line('Child ID: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).child_id);
		    dbms_output.put_line('Child Identification Number: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).child_id_num);
		    dbms_output.put_line('Child Name: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).child_name);
		    dbms_output.put_line('Child Type: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).child_type);
		    dbms_output.put_line('Child Purpose Code: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).child_purpose_code);
		    dbms_output.put_line('Child Purpose: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).child_purpose);
		    dbms_output.put_line('Description: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).description);
		    dbms_output.put_line('Status Code: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).status_code);
		    dbms_output.put_line('Status: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).status);
		    dbms_output.put_line('Child Sequence: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).child_sequence);
		    dbms_output.put_line('Depth: '||chr(9)||chr(9)||chr(9)|| x_hier_members_tab(i).depth);
		END LOOP;
	END IF;

		IF x_hier_attr_row_tab IS NOT NULL AND x_hier_attr_row_tab.COUNT > 0 THEN
			FOR row_index in x_hier_attr_row_tab.FIRST .. x_hier_attr_row_tab.LAST
			LOOP
				DBMS_OUTPUT.PUT_LINE('===========================================');
				DBMS_OUTPUT.PUT_LINE('ROW ID: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_row_tab(row_index).ROW_IDENTIFIER);
				DBMS_OUTPUT.PUT_LINE('ATTR_GROUP_ID: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_row_tab(row_index).ATTR_GROUP_ID);
				DBMS_OUTPUT.PUT_LINE('ATTR_GROUP_APP_ID: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_row_tab(row_index).ATTR_GROUP_APP_ID);
				DBMS_OUTPUT.PUT_LINE('ATTR_GROUP_TYPE: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_row_tab(row_index).ATTR_GROUP_TYPE);
				DBMS_OUTPUT.PUT_LINE('ATTR_GROUP_NAME: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_row_tab(row_index).ATTR_GROUP_NAME);
				DBMS_OUTPUT.PUT_LINE('DATA_LEVEL: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_row_tab(row_index).DATA_LEVEL);

				IF x_hier_attr_data_tab IS NOT NULL AND x_hier_attr_data_tab.COUNT > 0 THEN
					FOR data_index in x_hier_attr_data_tab.FIRST .. x_hier_attr_data_tab.LAST
					LOOP
						IF x_hier_attr_data_tab(data_index).ROW_IDENTIFIER <> x_hier_attr_row_tab(row_index).ROW_IDENTIFIER THEN
							EXIT;
						END IF;

						DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
						DBMS_OUTPUT.PUT_LINE('ROW ID: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_data_tab(data_index).ROW_IDENTIFIER);
						DBMS_OUTPUT.PUT_LINE('ATTR_NAME: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_data_tab(data_index).ATTR_NAME);
						DBMS_OUTPUT.PUT_LINE('ATTR_VALUE_STR: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_data_tab(data_index).ATTR_VALUE_STR);
						DBMS_OUTPUT.PUT_LINE('ATTR_VALUE_NUM: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_data_tab(data_index).ATTR_VALUE_NUM);
						DBMS_OUTPUT.PUT_LINE('ATTR_VALUE_DATE: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_data_tab(data_index).ATTR_VALUE_DATE);
						DBMS_OUTPUT.PUT_LINE('ATTR_DISP_VALUE: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_data_tab(data_index).ATTR_DISP_VALUE);
						DBMS_OUTPUT.PUT_LINE('ATTR_UNIT_OF_MEASURE: ' ||chr(9)||chr(9)||chr(9)|| x_hier_attr_data_tab(data_index).ATTR_UNIT_OF_MEASURE);

					END LOOP;
				END IF;
			END LOOP;
	END IF;
END;*/


END RRS_HIERARCHY_INFO;

/
