--------------------------------------------------------
--  DDL for Package INV_ITEM_CATEGORY_OI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_CATEGORY_OI" AUTHID CURRENT_USER AS
/* $Header: INVCICIS.pls 120.3.12010000.3 2010/05/26 11:01:18 kjonnala ship $ */

------------------------------ Global variables -------------------------------

g_xset_id         NUMBER  :=  fnd_api.g_MISS_NUM;
g_user_id         NUMBER  :=  -1;
g_login_id        NUMBER  :=  -1;
g_prog_appid      NUMBER  :=  -1;
g_prog_id         NUMBER  :=  -1;
g_request_id      NUMBER  :=  -1;


------------------------ process_Item_Category_records ------------------------

PROCEDURE process_Item_Category_records
(
   ERRBUF              OUT  NOCOPY VARCHAR2
,  RETCODE             OUT  NOCOPY NUMBER
,  p_rec_set_id        IN   NUMBER
,  p_upload_rec_flag   IN   NUMBER    :=  1
,  p_delete_rec_flag   IN   NUMBER    :=  1
,  p_commit_flag       IN   NUMBER    :=  1
,  p_prog_appid        IN   NUMBER    :=  NULL
,  p_prog_id           IN   NUMBER    :=  NULL
,  p_request_id        IN   NUMBER    :=  NULL
,  p_user_id           IN   NUMBER    :=  NULL
,  p_login_id          IN   NUMBER    :=  NULL
,  p_gather_stats      IN   NUMBER    :=  1  /* Added for Bug 8532728 */
,  p_validate_rec_flag IN   NUMBER  DEFAULT 1 /*Fix for bug 9714783 - moved p_validate_rec_flag parameter to the end*/
);


------------------------------ delete_OI_records ------------------------------

PROCEDURE delete_OI_records
(
   p_commit         IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
,  p_rec_set_id     IN   NUMBER
,  x_return_status  OUT  NOCOPY VARCHAR2
);


END INV_ITEM_CATEGORY_OI;

/
