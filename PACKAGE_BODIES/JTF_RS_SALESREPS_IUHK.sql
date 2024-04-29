--------------------------------------------------------
--  DDL for Package Body JTF_RS_SALESREPS_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_SALESREPS_IUHK" AS
  /* $Header: jtfrsnsb.pls 120.0 2005/05/11 08:20:56 appldev ship $ */

  /*****************************************************************************************
   This is the Internal Industry User Hook API.
   The Internal Industry can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Internal Industry Procedure for pre processing in case of
	create salesrep */

  PROCEDURE  create_salesrep_pre
  (P_RESOURCE_ID                    IN   JTF_RS_SALESREPS.RESOURCE_ID%TYPE,
   P_SALES_CREDIT_TYPE_ID           IN   JTF_RS_SALESREPS.SALES_CREDIT_TYPE_ID%TYPE,
   P_NAME                           IN   JTF_RS_SALESREPS.NAME%TYPE,
   P_STATUS                         IN   JTF_RS_SALESREPS.STATUS%TYPE,
   P_START_DATE_ACTIVE              IN   JTF_RS_SALESREPS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE                IN   JTF_RS_SALESREPS.END_DATE_ACTIVE%TYPE,
   P_GL_ID_REV                      IN   JTF_RS_SALESREPS.GL_ID_REV%TYPE,
   P_GL_ID_FREIGHT                  IN   JTF_RS_SALESREPS.GL_ID_FREIGHT%TYPE,
   P_GL_ID_REC                      IN   JTF_RS_SALESREPS.GL_ID_REC%TYPE,
   P_SET_OF_BOOKS_ID                IN   JTF_RS_SALESREPS.SET_OF_BOOKS_ID%TYPE,
   P_SALESREP_NUMBER                IN   JTF_RS_SALESREPS.SALESREP_NUMBER%TYPE,
   P_EMAIL_ADDRESS                  IN   JTF_RS_SALESREPS.EMAIL_ADDRESS%TYPE,
   P_WH_UPDATE_DATE                 IN   JTF_RS_SALESREPS.WH_UPDATE_DATE%TYPE,
   P_SALES_TAX_GEOCODE              IN   JTF_RS_SALESREPS.SALES_TAX_GEOCODE%TYPE,
   P_SALES_TAX_INSIDE_CITY_LIMITS   IN   JTF_RS_SALESREPS.SALES_TAX_INSIDE_CITY_LIMITS%TYPE,
   X_RETURN_STATUS                  OUT NOCOPY VARCHAR2
  ) IS
  begin
	null;
  end create_salesrep_pre;


  /* Internal Industry Procedure for post processing in case of
	create salesrep */

  PROCEDURE  create_salesrep_post
  (P_SALESREP_ID    	            IN   JTF_RS_SALESREPS.SALESREP_ID%TYPE,
   P_RESOURCE_ID                    IN   JTF_RS_SALESREPS.RESOURCE_ID%TYPE,
   P_SALES_CREDIT_TYPE_ID           IN   JTF_RS_SALESREPS.SALES_CREDIT_TYPE_ID%TYPE,
   P_NAME                           IN   JTF_RS_SALESREPS.NAME%TYPE,
   P_STATUS                         IN   JTF_RS_SALESREPS.STATUS%TYPE,
   P_START_DATE_ACTIVE              IN   JTF_RS_SALESREPS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE                IN   JTF_RS_SALESREPS.END_DATE_ACTIVE%TYPE,
   P_GL_ID_REV                      IN   JTF_RS_SALESREPS.GL_ID_REV%TYPE,
   P_GL_ID_FREIGHT                  IN   JTF_RS_SALESREPS.GL_ID_FREIGHT%TYPE,
   P_GL_ID_REC                      IN   JTF_RS_SALESREPS.GL_ID_REC%TYPE,
   P_SET_OF_BOOKS_ID                IN   JTF_RS_SALESREPS.SET_OF_BOOKS_ID%TYPE,
   P_SALESREP_NUMBER                IN   JTF_RS_SALESREPS.SALESREP_NUMBER%TYPE,
   P_EMAIL_ADDRESS                  IN   JTF_RS_SALESREPS.EMAIL_ADDRESS%TYPE,
   P_WH_UPDATE_DATE                 IN   JTF_RS_SALESREPS.WH_UPDATE_DATE%TYPE,
   P_SALES_TAX_GEOCODE              IN   JTF_RS_SALESREPS.SALES_TAX_GEOCODE%TYPE,
   P_SALES_TAX_INSIDE_CITY_LIMITS   IN   JTF_RS_SALESREPS.SALES_TAX_INSIDE_CITY_LIMITS%TYPE,
   X_RETURN_STATUS                  OUT NOCOPY VARCHAR2
  ) IS
  begin
	null;
  end create_salesrep_post;


  /* Internal Industry Procedure for pre processing in case of
	update salesrep */

  PROCEDURE  update_salesrep_pre
  (P_SALESREP_ID    	            IN   JTF_RS_SALESREPS.SALESREP_ID%TYPE,
   P_SALES_CREDIT_TYPE_ID           IN   JTF_RS_SALESREPS.SALES_CREDIT_TYPE_ID%TYPE,
   P_NAME                           IN   JTF_RS_SALESREPS.NAME%TYPE,
   P_STATUS                         IN   JTF_RS_SALESREPS.STATUS%TYPE,
   P_START_DATE_ACTIVE              IN   JTF_RS_SALESREPS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE                IN   JTF_RS_SALESREPS.END_DATE_ACTIVE%TYPE,
   P_GL_ID_REV                      IN   JTF_RS_SALESREPS.GL_ID_REV%TYPE,
   P_GL_ID_FREIGHT                  IN   JTF_RS_SALESREPS.GL_ID_FREIGHT%TYPE,
   P_GL_ID_REC                      IN   JTF_RS_SALESREPS.GL_ID_REC%TYPE,
   P_SET_OF_BOOKS_ID                IN   JTF_RS_SALESREPS.SET_OF_BOOKS_ID%TYPE,
   P_SALESREP_NUMBER                IN   JTF_RS_SALESREPS.SALESREP_NUMBER%TYPE,
   P_EMAIL_ADDRESS                  IN   JTF_RS_SALESREPS.EMAIL_ADDRESS%TYPE,
   P_WH_UPDATE_DATE                 IN   JTF_RS_SALESREPS.WH_UPDATE_DATE%TYPE,
   P_SALES_TAX_GEOCODE              IN   JTF_RS_SALESREPS.SALES_TAX_GEOCODE%TYPE,
   P_SALES_TAX_INSIDE_CITY_LIMITS   IN   JTF_RS_SALESREPS.SALES_TAX_INSIDE_CITY_LIMITS%TYPE,
   X_RETURN_STATUS                  OUT NOCOPY VARCHAR2
  ) IS
  begin
	null;
  end update_salesrep_pre;


  /* Internal Industry Procedure for post processing in case of
	update salesrep */

  PROCEDURE  update_salesrep_post
  (P_SALESREP_ID    	            IN   JTF_RS_SALESREPS.SALESREP_ID%TYPE,
   P_SALES_CREDIT_TYPE_ID           IN   JTF_RS_SALESREPS.SALES_CREDIT_TYPE_ID%TYPE,
   P_NAME                           IN   JTF_RS_SALESREPS.NAME%TYPE,
   P_STATUS                         IN   JTF_RS_SALESREPS.STATUS%TYPE,
   P_START_DATE_ACTIVE              IN   JTF_RS_SALESREPS.START_DATE_ACTIVE%TYPE,
   P_END_DATE_ACTIVE                IN   JTF_RS_SALESREPS.END_DATE_ACTIVE%TYPE,
   P_GL_ID_REV                      IN   JTF_RS_SALESREPS.GL_ID_REV%TYPE,
   P_GL_ID_FREIGHT                  IN   JTF_RS_SALESREPS.GL_ID_FREIGHT%TYPE,
   P_GL_ID_REC                      IN   JTF_RS_SALESREPS.GL_ID_REC%TYPE,
   P_SET_OF_BOOKS_ID                IN   JTF_RS_SALESREPS.SET_OF_BOOKS_ID%TYPE,
   P_SALESREP_NUMBER                IN   JTF_RS_SALESREPS.SALESREP_NUMBER%TYPE,
   P_EMAIL_ADDRESS                  IN   JTF_RS_SALESREPS.EMAIL_ADDRESS%TYPE,
   P_WH_UPDATE_DATE                 IN   JTF_RS_SALESREPS.WH_UPDATE_DATE%TYPE,
   P_SALES_TAX_GEOCODE              IN   JTF_RS_SALESREPS.SALES_TAX_GEOCODE%TYPE,
   P_SALES_TAX_INSIDE_CITY_LIMITS   IN   JTF_RS_SALESREPS.SALES_TAX_INSIDE_CITY_LIMITS%TYPE,
   X_RETURN_STATUS                  OUT NOCOPY VARCHAR2
  ) IS
  begin
	null;
  end update_salesrep_post;


END jtf_rs_salesreps_iuhk;

/
