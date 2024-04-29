--------------------------------------------------------
--  DDL for Package JTF_RS_DBI_CONC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_DBI_CONC_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrsdbs.pls 120.0 2005/05/11 08:19:48 appldev noship $ */
/*#
 * Group Hierarchy API for DBI products.
 * This API contains Group Hierarchy related procedures and functions
 * which is used by DBI products. This program has Oracle 9i dependency.
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Group Hierarchy API for DBI products
 * @rep:category BUSINESS_ENTITY JTF_RS_SALES_GROUP_HIERARCHY
*/


/*#
 * Populate Sales Group Hierarchy concurrant program
 * This procedure populates sales group hierarchy data through concurrant program.
 * @param errbuf Output parameter for error buffer
 * @param retcode Output parameter for return code
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Populate Sales Group Hierarchy concurrant program
*/

  /****************************************************************************
   This is a concurrent program to populate the data that can be accessed via view
   JTF_RS_DBI_RES_GRP_VL for Sales Group Hierarchy (usage : SALES) in DBI
   product.

   This program is exclusively built for DBI product and is NOT included in
   mainline code of ATG Resource Manager.

   Created By       nsinghai      16-Jan-2003
   ***************************************************************************/

  PROCEDURE  populate_res_grp
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2)
   ;

/*#
 * Get Sales Group Id
 * Function to get sales group id. Based on user id, this function will return
 * a group id in which logged in user is manager or administrator.
 * @return Group Id
 * @rep:scope internal
 * @rep:displayname Get Sales Group Id
*/

  /****************************************************************************
      This function is for providing a common method of fetching the group id
      for first time login pages. Instead of passing '-1111' to Sales Group
      Dimension LOV, product teams will call this function which will return
      them a valid group id. This group id will be used by product teams to
      query the data rather then querying data for dummy group '-1111'.
      Internally this function will query for '-1111' and then return the first
      record. This is for usage : 'SALES'

   Created By      nsinghai      03-Oct-2003
   ***************************************************************************/

  FUNCTION get_sg_id RETURN VARCHAR2;

/*#
 * Populate Field Service District Hierarchy concurrant program
 * This procedure populates Field Service District hierarchy data through
 * concurrant program.
 * @param errbuf Output parameter for error buffer
 * @param retcode Output parameter for return code
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Populate Field Service District Hierarchy concurrant program
*/

  /****************************************************************************
   This is concurrent program to populate the data that can be accessed via view
   JTF_RS_DBI_RES_GRP_VL for usage 'FLD_SRV_DISTRICT' (Field Service District
   Hierarchy) in DBI product.

   This program is exclusively built for DBI product and is NOT included in
   mainline code of ATG Resource Manager.

   Created By       nsinghai      01-JUL-2004
   ***************************************************************************/

  PROCEDURE  populate_fld_srv_district
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2)
   ;

/*#
 * Populate Group Hierarchy procdure (For Internal Use Only)
 * This procedure does processing depending on where it is called from.
 * @param p_usage Input parameter for processing logic
 * @param p_errbuf Output parameter for error buffer
 * @param p_retcode Output parameter for return code
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Populate Main procedure
*/

  /****************************************************************************
   This is main procedure to populate the data in JTF_RS_DBI_MGR_GROUPS
   and JTF_RS_DBI_DENORM_RES_GROUPS table so that it can be accessed via view
   JTF_RS_DBI_RES_GRP_VL for usage 'SALES' (Sales Group Hierarchy) and
   'FLD_SRV_DISTRICT' (Field Service District Hierarchy) in DBI product.

   This program is exclusively built for DBI product and is NOT included in
   mainline code of ATG Resource Manager.

   Created By       nsinghai      01-JUL-2004
   ***************************************************************************/

  PROCEDURE  populate_main
  (P_USAGE                   IN  VARCHAR2,
   P_ERRBUF                  OUT NOCOPY VARCHAR2,
   P_RETCODE                 OUT NOCOPY VARCHAR2)
   ;

/*#
 * Get Field Service District Id
 * Function to get Field Service District Id. Based on user id, this function
 * will return a group id in which logged in user is manager or administrator
 * for Field Service Groups (Usage: 'FLD_SRV_DISTRICT').
 * @return Group Id
 * @rep:scope internal
 * @rep:displayname Get Field Service District Id
*/

  /****************************************************************************
      This function is for providing a common method of fetching the group id
      for first time login pages. Instead of passing '-1111' to Group Hierarchy
      Dimension LOV, product teams will call this function which will return
      them a valid group id. This group id will be used by Field Service team to
      query the data rather then querying data for dummy group '-1111'.
      Internally this function will query for '-1111' and then return the first
      record. This is for Field Service Districts (Usage: 'FLD_SRV_DISTRICT').

   Created By      nsinghai      01-JUL-2004
   ***************************************************************************/

  FUNCTION get_fsg_id RETURN VARCHAR2;

/*#
 * Get First Time Login Group Id
 * Function to get first Time Login group id. Based on user id and Usage,
 * this function will return a group id in which logged in user is
 * manager or administrator. It can be used for all usages.
 * @param p_include_member_groups Input parameter (Y/N) to check if member groups have to be considered or not
 * @param p_usage Input parameter (Usage) for fetching group id logic
 * @return Group Id
 * @rep:scope internal
 * @rep:displayname Get First Time Login Group Id
*/

  /****************************************************************************
      This function is for providing a common method of fetching the group id
      for first time login pages. Instead of passing '-1111' to Sales Group
      Dimension LOV, product teams will call this function which will return
      them a valid group id. This group id will be used by product teams to
      query the data rather then querying data for dummy group '-1111'.
      Internally this function will query for '-1111' and then return the first
      record. This can be used for all usages

   Created By      nsinghai      15-Jul-2004
   ***************************************************************************/

  FUNCTION get_first_login_group_id(p_usage VARCHAR2, p_include_member_groups VARCHAR2 ) RETURN VARCHAR2;

/*#
 * Get First Time Login Group Id Including Members for Sales
 * Function to get first Time Login group id. Based on user id,
 * this function will return a group id in which logged in user is
 * manager, administrator or Member. It is used for usage 'SALES'.
 * @return Group Id
 * @rep:scope internal
 * @rep:displayname Get First Time Login Group Id
*/

  /****************************************************************************
      This function is for providing a common method of fetching the group id
      for first time login pages. Instead of passing '-1111' to Sales Group
      Dimension LOV, product teams will call this function which will return
      them a valid group id. This group id will be used by product teams to
      query the data rather then querying data for dummy group '-1111'.
      Internally this function will query for '-1111' and then return the first
      record. This is for usage : 'SALES'

      "get_sg_id" returns first time login id only from managers and admin groups
	  for sales
      "get_sg_id_all_login" returns first time login id only from managers, admin
	  and member groups for sales

     Created By      nsinghai      08-Oct-2004
   ***************************************************************************/

  FUNCTION get_sg_id_all_login RETURN VARCHAR2;

/*#
 * Get First Time Login Group Id Including Members for Field Service
 * Function to get first Time Login group id. Based on user id,
 * this function will return a group id in which logged in user is
 * manager, administrator or Member. It is used for usage 'FLD_SRV_DISTRICT'.
 * @return Group Id
 * @rep:scope internal
 * @rep:displayname Get First Time Login Group Id
*/
  /****************************************************************************
      This function is for providing a common method of fetching the group id
      for first time login pages. Instead of passing '-1111' to Sales Group
      Dimension LOV, product teams will call this function which will return
      them a valid group id. This group id will be used by product teams to
      query the data rather then querying data for dummy group '-1111'.
      Internally this function will query for '-1111' and then return the first
      record. This is for usage : 'FLD_SRV_DISTRICT'

      "get_fsg_id" returns first time login id only from managers and admin groups
	  for field service
      "get_fsg_id_all_login" returns first time login id only from managers, admin
	  and member groups for field service

     Created By      nsinghai      08-Oct-2004
   ***************************************************************************/

  FUNCTION get_fsg_id_all_login RETURN VARCHAR2;

END jtf_rs_dbi_conc_pub;

 

/
