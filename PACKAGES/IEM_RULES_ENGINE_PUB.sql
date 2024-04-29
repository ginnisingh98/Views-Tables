--------------------------------------------------------
--  DDL for Package IEM_RULES_ENGINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_RULES_ENGINE_PUB" AUTHID CURRENT_USER AS
/* $Header: iempruls.pls 120.0.12010000.2 2009/07/13 04:51:23 lkullamb ship $ */
--
--
-- Purpose: Email Processing Engine to process emails based on the rules
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   06/10/2002   Create
--  Liang Xia   12/04/2002   Fixed gscc warning: NOCOPY, No G_miss...
--  Liang Xia   07/06/2003   Added Document Mapping validation
--  Liang Xia   08/17/2003   Added Auto-Redirect rule type
--  Liang Xia   09/24/2003   Added extra validation on AUTOACKNOWLEDGE,
--                           AUTOREPLYSPECDOC to check if the document is exist
--  lkullamb    7/13/2009    Added parameter3 to parameter_type record type
-- ---------   ------  ------------------------------------------

  TYPE parameter_type is RECORD (
    parameter1      iem_action_dtls.parameter1%type,
    parameter2      iem_action_dtls.parameter2%type,
    parameter3      iem_action_dtls.parameter3%type,
    type            varchar2(30)
    );

  --Table of Key-Values
  TYPE parameter_tbl_type is TABLE OF parameter_type INDEX BY BINARY_INTEGER;

  PROCEDURE auto_process_email(
  p_api_version_number  IN Number,
  p_init_msg_list       IN VARCHAR2 := null,
  p_commit              IN VARCHAR2 := null,
  p_rule_type           IN VARCHAR2,
  p_keyVals_tbl         IN IEM_ROUTE_PUB.keyVals_tbl_type,
  p_accountId           IN Number,
  x_result              OUT NOCOPY VARCHAR2,
  x_action              OUT NOCOPY Varchar2,
  x_parameters          OUT NOCOPY IEM_RULES_ENGINE_PUB.parameter_tbl_type,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2);

function is_valid ( p_value VARCHAR2 )
   return VARCHAR2;

function get_document_total ( p_cat_id VARCHAR2 )
   return NUMBER;

function is_document_exist ( p_cat_id VARCHAR2, p_doc_id VARCHAR2 )
    return VARCHAR2;

END IEM_RULES_ENGINE_PUB;

/
