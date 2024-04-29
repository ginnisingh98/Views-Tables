--------------------------------------------------------
--  DDL for Package RRS_SITE_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RRS_SITE_INFO" AUTHID DEFINER  as
/* $Header: RRSGSDTS.pls 120.0.12010000.15 2009/08/31 20:58:01 sunarang noship $ */
/*#
 This package is created for retrieving the Site Details from Site Hub.
 It will accept Site Identification Number as an input Parameter and will
 retrieve all the relative information for the Site depending on the
 procedure call.
 It has various procedures for returning information related to a specific
 Site.
<code><pre>
 There are 6 categories of information , which this API can retrieve.
</pre></code>

<code><pre>
 1. Basic Attributes of a Site and Basic details ( like Address and Purpose )
</pre></code>
<code><pre>
 2. Associations of a site. ( like Trade Areas , Clusters and Hierarchy )
</pre></code>
<code><pre>
 3. Attributes of a Site ( These are the UDA's for various entities i.e. Site
 , Location and Trade Area ).
</pre></code>
<code><pre>
 4. Contacts of a Site ( like Phone , Email , URL and other contact details )
</pre></code>
<code><pre>
 5. Attachments related to the Site. ( If there are any documents of links
 created as an attachments for this Site )
</pre></code>
<code><pre>
 6. Asset Details attached to this Site ( like Details of any assets attached
 to this site )
</pre></code>

 For retrieving all these above details for a Site , we need to call
 Get_complete_site_details() procedure with input as a Site Number.

 Every procedure returns a collection with relevant information retrieved
 from these procedures. These are the collections which are returned from
 various procedures.
<code><pre>
    	CREATE TYPE  RRS_SITE_HEADER_TAB AS TABLE OF RRS_SITE_HEADER_REC;
</pre></code>

<code><pre>
	CREATE TYPE  RRS_SITE_ADDRESS_TAB IS TABLE OF RRS_SITE_ADDRESS_REC;
</pre></code>

<code><pre>
	CREATE TYPE  RRS_SITE_USES_TAB IS TABLE OF RRS_SITE_USES_REC;
</pre></code>

<code><pre>
	CREATE TYPE  RRS_SITE_CLUSTER_TAB IS TABLE OF RRS_SITE_CLUSTER_REC;
</pre></code>

<code><pre>
	CREATE TYPE  RRS_SITE_HIERAR_TAB IS TABLE OF RRS_SITE_HIERAR_REC;
</pre></code>

<code><pre>
	CREATE TYPE  RRS_TRADE_AREA_GRP_TAB IS TABLE OF RRS_TRADE_AREA_GRP_REC;
</pre></code>

<code><pre>
	CREATE TYPE  RRS_RELATIONSHIP_TAB IS TABLE OF RRS_RELATIONSHIP_REC;
</pre></code>

<code><pre>
	CREATE TYPE  RRS_SITE_PHONE_TAB IS TABLE OF  RRS_SITE_PHONE_REC;
</pre></code>

<code><pre>
	CREATE TYPE  RRS_SITE_EMAIL_TAB IS TABLE OF RRS_SITE_EMAIL_REC;
</pre></code>

<code><pre>
	CREATE TYPE  RRS_SITE_URL_TAB IS TABLE OF RRS_SITE_URL_REC;
</pre></code>

<code><pre>
	CREATE TYPE  RRS_SITE_PERSON_TAB IS TABLE OF RRS_SITE_PERSON_REC;
</pre></code>

<code><pre>
	CREATE TYPE  RRS_SITE_ATTACHMENT_TAB IS TABLE OF RRS_SITE_ATTACHMENT_REC;
</pre></code>

<code><pre>
	CREATE TYPE  RRS_SITE_ASSET_TAB IS TABLE OF RRS_SITE_ASSET_REC;
</pre></code>

<code><pre>
	CREATE TYPE  RRS_PROPERTY_TAB IS TABLE OF RRS_PROPERTY_REC;
</pre></code>

*@rep:scope public
*@rep:product RRS
*@rep:displayname Get Site Information
*@rep:lifecycle active
*@rep:compatibility N
*@rep:category BUSINESS_ENTITY RRS_SITE
*/



--
-- Get_complete_site_details (PUBLIC)
--   Retrieve all the details of a specific Site.
-- IN:
--   p_site_id_num - Site Identification Number
--
/*#
 * Retrieves all the information of a particular site.
 * @param p_site_id_num Site Identification Number
 * @param p_site_name Site Name
 * @param p_page_name Page Name for Attributes
 * @param x_site_header_tab Collection object returning Site Header Details
 * @param x_site_address_tab Collection object returning Site Address Details
 * @param x_party_site_address_tab Collection object returning Site Address Details
 * @param x_site_uses_tab Collection object returning Purpose of Site
 * @param x_property_tab Collection object returning Entities or Property Details
 * @param x_site_cluster_tab Collection object returning Cluster Information
 * @param x_site_hierar_tab Collection object returning Hierarchy Information
 * @param x_trade_area_grp_tab Collection object returning Trade Area Group Details
 * @param x_relationship_tab Collection object returning relationships Details
 * @param x_site_phone_tab Collection object returning Phone Details for a Site
 * @param x_site_email_tab Collection object returning Email Details of a Site
 * @param x_site_url_tab Collection object returning URL Details for a Site
 * @param x_site_person_tab Collection object returning Person Details
 * @param x_site_attachment_tab Collection object returning Attachment Details
 * @param x_site_asset_tab Collection object returning Asset Information
 * @param x_site_attrib_row_table Collection object returning UDA for Entity Site
 * @param x_site_attrib_data_table Collection object returning UDA for Entity Site
 * @param x_loc_attrib_row_table Collection object returning UDA for Entity Location
 * @param x_loc_attrib_data_table Collection object returning UDA for Entity Location
 * @param x_tr_area_attrib_row_table Collection object returning UDA for Entity Trade Area
 * @param x_tr_area_attrib_data_table Collection object returning UDA for Entity Trade Area
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Complete Site Details
 */


Procedure Get_complete_site_details(
 p_site_id_num                  IN              varchar2
,p_site_name                    IN              varchar2 Default null
,p_page_name                    IN              varchar2 Default null
,x_site_header_tab              OUT NOCOPY      rrs_site_header_tab
,x_site_address_tab             OUT NOCOPY      rrs_site_address_tab
,x_site_uses_tab                OUT NOCOPY      rrs_site_uses_tab
,x_party_site_address_tab       OUT NOCOPY      rrs_site_address_tab
,x_property_tab                 OUT NOCOPY      rrs_property_tab
,x_site_cluster_tab             OUT NOCOPY      rrs_site_cluster_tab
,x_site_hierar_tab              OUT NOCOPY      rrs_site_hierar_tab
,x_trade_area_grp_tab           OUT NOCOPY      rrs_trade_area_grp_tab
,x_relationship_tab             OUT NOCOPY      rrs_relationship_tab
,x_site_phone_tab               OUT NOCOPY      rrs_site_phone_tab
,x_site_email_tab               OUT NOCOPY      rrs_site_email_tab
,x_site_url_tab                 OUT NOCOPY      rrs_site_url_tab
,x_site_person_tab              OUT NOCOPY      rrs_site_person_tab
,x_site_attachment_tab          OUT NOCOPY      rrs_site_attachment_tab
,x_site_asset_tab               OUT NOCOPY      rrs_site_asset_tab
,x_site_attrib_row_table        OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_site_attrib_data_table       OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
,x_loc_attrib_row_table         OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_loc_attrib_data_table        OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
,x_tr_area_attrib_row_table     OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_tr_area_attrib_data_table    OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
);


--
-- Get_site_details (PUBLIC)
--   Retrieve the Header information and Basic attributes of a Site.
-- IN:
--   p_site_id_num - Site Identification Number
--
/*#
 * Retrieves Header and Basic information of a particular site.
 * @param p_site_id_num Site Identification Number
 * @param p_site_name Site Name
 * @param x_site_header_tab Collection object returning Site Header Details
 * @param x_site_address_tab Collection object returning Site Address Details
 * @param x_site_uses_tab Collection object returning Purpose of Site
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Site Details
 */


Procedure Get_site_details(
 p_site_id_num 			IN 		varchar2
,p_site_name   			IN 		varchar2 Default null
,x_site_header_tab              OUT NOCOPY      rrs_site_header_tab
,x_site_address_tab             OUT NOCOPY      rrs_site_address_tab
,x_site_uses_tab                OUT NOCOPY      rrs_site_uses_tab
);


--
-- Get_site_complete_attributes (PUBLIC)
--   Retrieves User Defined Attributes for a specific Site.
-- IN:
--   p_site_id_num - Site Identification Number
--   p_site_name   - Page Name for which attributes to display.
--
/*#
 * Retrieves Header and Basic information of a particular site.
 * @param p_site_id_num Site Identification Number
 * @param p_site_name Site Name
 * @param x_site_attrib_row_table Collection object returning UDA for Entity Site
 * @param x_site_attrib_data_table Collection object returning UDA for Entity Site
 * @param x_loc_attrib_row_table Collection object returning UDA for Entity Location
 * @param x_loc_attrib_data_table Collection object returning UDA for Entity Location
 * @param x_tr_area_attrib_row_table Collection object returning UDA for Entity Trade Area
 * @param x_tr_area_attrib_data_table Collection object returning UDA for Entity Trade Area
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Complete Site Attributes
 */


Procedure Get_site_complete_attributes(
 p_site_id_num                  IN              varchar2
,p_site_name                    IN              varchar2 Default null
,x_site_attrib_row_table        OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_site_attrib_data_table       OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
,x_loc_attrib_row_table         OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_loc_attrib_data_table        OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
,x_tr_area_attrib_row_table     OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_tr_area_attrib_data_table    OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
);


--
-- Get_site_attributes (PUBLIC)
--   Retrieves User Defined Attributes for a specific Site.
-- IN:
--   p_site_id_num - Site Identification Number
--   p_page_name   - Page Name for which attributes to display.
--
/*#
 * Retrieves Attributes information for Entity type Site.
 * @param p_site_id_num Site Identification Number
 * @param p_site_name Site Name
 * @param p_page_name Page Name for Attributes
 * @param x_site_attrib_row_table Collection object returning UDA for Entity Site
 * @param x_site_attrib_data_table Collection object returning UDA for Entity Site
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Site Attributes
 */


Procedure Get_site_attributes(
 p_site_id_num 			IN 		varchar2
,p_site_name   			IN 		varchar2 Default null
,p_page_name 			IN 		varchar2 Default null
,x_site_attrib_row_table        OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_site_attrib_data_table       OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
);


--
-- Get_location_attributes (PUBLIC)
--   Retrieves User Defined Attributes for a specific Site for Location Entity.
-- IN:
--   p_site_id_num - Site Identification Number
--   p_page_name   - Page Name for which attributes to display.
--
/*#
 * Retrieves Attributes information for Entity type Location.
 * @param p_site_id_num Site Identification Number
 * @param p_site_name Site Name
 * @param p_page_name Page Name for Attributes
 * @param x_loc_attrib_row_table Collection object returning UDA for Entity Location
 * @param x_loc_attrib_data_table Collection object returning UDA for Entity Location
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Location Attributes
 */

Procedure Get_location_attributes(
 p_site_id_num                  IN              varchar2
,p_site_name                    IN              varchar2 Default null
,p_page_name                    IN              varchar2 Default null
,x_loc_attrib_row_table         OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_loc_attrib_data_table        OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
);

--
-- Get_trade_area_attributes (PUBLIC)
--   Retrieves User Defined Attributes for a specific Site for Trade Area Entity.
-- IN:
--   p_site_id_num - Site Identification Number
--   p_page_name   - Page Name for which attributes to display.
--
/*#
 * Retrieves Attributes information for Entity type Trade Area.
 * @param p_site_id_num Site Identification Number
 * @param p_site_name Site Name
 * @param p_page_name Page Name for Attributes
 * @param x_tr_area_attrib_row_table Collection object returning UDA for Entity Trade Area
 * @param x_tr_area_attrib_data_table Collection object returning UDA for Entity Trade Area
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Trade Area Attributes
 */

Procedure Get_trade_area_attributes(
 p_site_id_num                  IN              varchar2
,p_site_name                    IN              varchar2 Default null
,p_page_name                    IN              varchar2 Default null
,x_tr_area_attrib_row_table     OUT NOCOPY      EGO_USER_ATTR_ROW_TABLE
,x_tr_area_attrib_data_table    OUT NOCOPY      EGO_USER_ATTR_DATA_TABLE
);


--
-- Get_site_associations (PUBLIC)
--   Retrieves Trade areas , clusters and Hierarchy information for a site.
-- IN:
--   p_site_id_num - Site Identification Number
--
/*#
 * Retrieves Trade areas , clusters and Hierarchy information for a site.
 * @param p_site_id_num Site Identification Number
 * @param p_site_name Site Name
 * @param x_property_tab Collection object returning Entities or Property Details
 * @param x_site_cluster_tab Collection object returning Cluster Information
 * @param x_site_hierar_tab Collection object returning Hierarchy Information
 * @param x_trade_area_grp_tab Collection object returning Trade Area Group Details
 * @param x_relationship_tab Collection object returning relationships Details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Site Associations
 */


Procedure Get_site_associations(
 p_site_id_num 			IN 		varchar2
,p_site_name   			IN 		varchar2 Default null
,x_property_tab                 OUT NOCOPY      rrs_property_tab
,x_site_cluster_tab 		OUT NOCOPY 	rrs_site_cluster_tab
,x_site_hierar_tab 		OUT NOCOPY	rrs_site_hierar_tab
,x_trade_area_grp_tab 		OUT NOCOPY	rrs_trade_area_grp_tab
,x_relationship_tab 		OUT NOCOPY	rrs_relationship_tab
);

--
-- Get_site_attachments (PUBLIC)
--   Retrieve the attachments associated with a specific Site.
-- IN:
--   p_site_id_num - Site Identification Number
--
/*#
 * Retrieve the attachments associated with a specific Site.
 * @param p_site_id_num Site Identification Number
 * @param p_site_name Site Name
 * @param x_site_attachment_tab Collection object returning Attachment Details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Site Attachments
 */


Procedure Get_site_attachments(
 p_site_id_num 				IN 		varchar2
,p_site_name   				IN 		varchar2 Default null
,x_site_attachment_tab                  OUT NOCOPY      rrs_site_attachment_tab
);


--
-- Get_site_contacts (PUBLIC)
--   Retrieves the contact details for a Site.
-- IN:
--   p_site_id_num - Site Identification Number
--
/*#
 * Retrieves the contact details for a Site.
 * @param p_site_id_num Site Identification Number
 * @param p_site_name Site Name
 * @param x_party_site_address_tab Collection object returning Site Address Details
 * @param x_site_phone_tab Collection object returning Phone Details for a Site
 * @param x_site_email_tab Collection object returning Email Details of a Site
 * @param x_site_url_tab Collection object returning URL Details for a Site
 * @param x_site_person_tab Collection object returning Person Details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Site Contacts
 */


Procedure Get_site_contacts(
 p_site_id_num 			IN 		varchar2
,p_site_name   			IN 		varchar2 Default null
,x_party_site_address_tab             OUT NOCOPY      rrs_site_address_tab
,x_site_phone_tab               OUT NOCOPY      rrs_site_phone_tab
,x_site_email_tab               OUT NOCOPY      rrs_site_email_tab
,x_site_url_tab                 OUT NOCOPY      rrs_site_url_tab
,x_site_person_tab              OUT NOCOPY      rrs_site_person_tab
);


--
-- Get_site_assets (PUBLIC)
--   Retrieve details of assets related to a Site.
-- IN:
--   p_site_id_num - Site Identification Number
--
/*#
 * Retrieve details of assets related to a Site.
 * @param p_site_id_num Site Identification Number
 * @param p_site_name Site Name
 * @param x_site_asset_tab Collection object returning Asset Information
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Site Assets
 */


Procedure Get_site_assets(
 p_site_id_num 			IN 		varchar2
,p_site_name   			IN 		varchar2 Default null
,x_site_asset_tab		OUT NOCOPY	rrs_site_asset_tab
);

end RRS_SITE_INFO;

/
