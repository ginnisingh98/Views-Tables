--------------------------------------------------------
--  DDL for Package JTF_RS_DBI_8I_CONC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_DBI_8I_CONC_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrsdas.pls 115.2 2004/06/25 18:17:38 baianand noship $ */
/*#
 * Sales Group Hierarchy API for non DBI products.
 * This API contains Sales Group hierarchy related procedures and functions
 * which is used exclusively by Oracle Sales Intelligence. They are Oracle 8i compatible.
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Sales Group Hierarchy API for non DBI products
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
   This is 8i compatible concurrent program
   This is a concurrent program to populate the data in JTF_RS_DBI_MGR_GROUPS
   and JTF_RS_DBI_DENORM_RES_GROUPS
   table so that it can be accessed via view JTF_RS_DBI_RES_GRP_VL for Sales
   Group Hierarchy in DBI product. This program is exclusively built for DBI
   product and is NOT included in mainline code of ATG Resource Manager.

   This is 8i version of regular DBI program

   Create By       nsinghai      27-Oct-2003
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
      record.

      This is 8i version of regular DBI program

   Created By      nsinghai      03-Oct-2003
   ***************************************************************************/

  FUNCTION get_sg_id RETURN VARCHAR2;


END jtf_rs_dbi_8i_conc_pub;

 

/
