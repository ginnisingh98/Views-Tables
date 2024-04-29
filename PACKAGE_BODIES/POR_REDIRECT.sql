--------------------------------------------------------
--  DDL for Package Body POR_REDIRECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_REDIRECT" AS
/* $Header: PORRDIRB.pls 120.0.12010000.2 2015/11/30 22:50:07 prilamur ship $*/

PROCEDURE REQSERVER(x_source varchar2 default null, -- not used
                    x_menuFunction varchar2 default null, -- not used
                    x_responsibilityID varchar2 default null,
                    x_object varchar2 default null,
                    x_doc_id number default null,
                    x_org_id number default null,
                    x_requester_id number default null,
            		    x_exp_receipt_date varchar2 default null,
                    x_param varchar2 default null)
IS


BEGIN

   -- Stubout the code as it is not used in 11.5.10 and higher and it has security issue Bug 22160633
  NULL;
END;

PROCEDURE process_navigator_redirect IS
  l_redirect_url varchar2(2000):=NULL;
  l_function VARCHAR2(500)     :=NULL;
  l_hostname varchar2(500)     :=NULL;
  l_progress varchar2(3)       :='000';
  l_application_id  NUMBER:= NULL;
  e_reqserver_not_set exception;
BEGIN

   -- Stubout the code as it is not used in 11.5.10 and higher and it has security issue Bug 22160633
  NULL;

END process_navigator_redirect;


END POR_REDIRECT;

/
