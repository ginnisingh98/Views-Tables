--------------------------------------------------------
--  DDL for Package OKC_REP_UPD_CON_ADMIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REP_UPD_CON_ADMIN_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKCVREPUADS.pls 120.2 2005/11/17 17:57:17 vamuru noship $ */

   ---------------------------------------------------------------------------
   -- GLOBAL CONSTANTS
   ---------------------------------------------------------------------------
   G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_REP_UPD_CON_ADMIN_PVT';
   G_APP_NAME                   CONSTANT   VARCHAR2(3)   := 'OKC';
   G_MODULE                     CONSTANT   VARCHAR2(250) := 'okc.plsql.'||G_PKG_NAME||'.';
   G_FND_APP                    CONSTANT   VARCHAR2(200) := OKC_API.G_FND_APP;

   ------------------------------------------------------------------------------
   -- GLOBAL EXCEPTION
   ------------------------------------------------------------------------------
   E_Resource_Busy               EXCEPTION;
   PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);


   ---------------------------------------------------------------------------
   -- Procedures and Functions
   ---------------------------------------------------------------------------

   -- Start of comments
   --API name      : update_con_admin_manager
   --Type          : Private.
   --Function      : API to update Contract Administrator of Blanket Sales
   --                Agreements, Sales Orders, Quotes and Repository Contracts
   --                (Sell and Other intent only)
   --Pre-reqs      : None.
   --Parameters    :
   --IN            : errbuf                  OUT NUMBER
   --              : retcode                 OUT VARCHAR2
   --              : p_doc_type              IN VARCHAR2    Required
   --                   Type of contracts whose administrator need to be modified
   --              : p_cust_id               IN NUMBER      Optional
   --                   Customer of contracts whose administrator need to be modified
   --              : p_prev_con_admin_id     IN NUMBER      Optional
   --                   Existing administrator of contracts whose administrator need to be modified
   --              : p_salesrep_id           IN NUMBER      Optional
   --                   Salesperson of contracts whose administrator need to be modified
   --              : p_sales_group_id        IN NUMBER      Optional
   --                   Sales Group of quotes whose administrator need to be modified
   --              : p_org_id                IN NUMBER      Optional
   --                   Operating unit of contracts whose administrator need to be modified
   --              : p_order_type_id         IN NUMBER      Optional
   --                   Order type of contracts whose administrator need to be modified
   --              : p_new_con_admin_id      IN NUMBER      Optional
   --                   New Contract Administrator Id
   --              : p_new_con_admin_name    IN VARCHAR2    Optional
   --                   New Contract Administrator Name
   --              : p_mode                  IN VARCHAR2    Optional
   --                   Mode of operation Preview Only or Update
   --              : p_con_admin_from        IN VARCHAR2    Required
   --                   Contract Administrator from, possible values are NEW_CON_ADMIN or SALES_GROUP_ASMT
   --Note          :
   -- End of comments
     PROCEDURE update_con_admin_manager(
       errbuf                  OUT NOCOPY VARCHAR2,
       retcode                 OUT NOCOPY VARCHAR2,
       p_doc_type              IN VARCHAR2,
       p_cust_id               IN NUMBER,
       p_prev_con_admin_id     IN NUMBER,
       p_salesrep_id           IN NUMBER,
       p_sales_group_id        IN NUMBER,
       p_org_id                IN NUMBER,
       p_order_type_id         IN NUMBER,
       p_new_con_admin_user_id IN NUMBER,
       p_new_con_admin_name    IN VARCHAR2,
       p_mode                  IN VARCHAR2,
       p_con_admin_from        IN VARCHAR2
     );


END OKC_REP_UPD_CON_ADMIN_PVT;

 

/
