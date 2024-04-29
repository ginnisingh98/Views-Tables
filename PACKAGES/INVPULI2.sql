--------------------------------------------------------
--  DDL for Package INVPULI2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPULI2" AUTHID CURRENT_USER as
/* $Header: INVPUL2S.pls 120.1.12010000.2 2008/07/29 13:43:51 ptkumar ship $ */

TYPE Import_Template_Tbl_Type IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

function copy_template_attributes(
   org_id     IN            NUMBER
  ,all_org    IN            NUMBER  := 2
  ,prog_appid IN            NUMBER  := -1
  ,prog_id    IN            NUMBER  := -1
  ,request_id IN            NUMBER  := -1
  ,user_id    IN            NUMBER  := -1
  ,login_id   IN            NUMBER  := -1
  ,xset_id    IN            NUMBER  := -999
  ,err_text   IN OUT NOCOPY VARCHAR2
) RETURN INTEGER;

/*------------------------------------------------------------------------------------

   Procedure for Applying the specfied template to the specified interface row.

------------------------------------------------------------------------------------*/

FUNCTION apply_multiple_template( p_template_tbl IN Import_Template_Tbl_Type
                                 ,p_org_id       IN NUMBER
                                 ,p_all_org      IN NUMBER  := 2
                                 ,p_prog_appid   IN NUMBER  := -1
                                 ,p_prog_id      IN NUMBER  := -1
                                 ,p_request_id   IN NUMBER  := -1
                                 ,p_user_id      IN NUMBER  := -1
                                 ,p_login_id     IN NUMBER  := -1
                                 ,p_xset_id      IN NUMBER  := -999
                                 ,x_err_text     IN OUT NOCOPY VARCHAR2)
RETURN INTEGER;

end INVPULI2;

/
