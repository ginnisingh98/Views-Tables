--------------------------------------------------------
--  DDL for Package HR_DE_TAX_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DE_TAX_SUPPORT" AUTHID CURRENT_USER AS
/* $Header: perdetbu.pkh 115.3 2002/01/25 04:47:51 pkm ship      $ */
--
procedure batch_update
( P_BUSINESS_GROUP_ID         IN NUMBER
, P_date_from                 IN DATE
, P_ORG_HIERARCHY             IN NUMBER
, P_TOP_ORG                   IN NUMBER
, P_ASSIGNMENT_SET            IN NUMBER
, P_ACTION                    IN VARCHAR2
, P_PROCESS_ID		      IN NUMBER
, P_TAX_CLASS                 IN VARCHAR2
, P_NO_OF_CHILDREN            IN VARCHAR2
, P_TAX_FREE_INCOME           IN VARCHAR2
, P_ADD_INCOME                IN VARCHAR2);


procedure tax_record
( P_BUSINESS_GROUP_ID         IN NUMBER
, P_date_from                 IN DATE
, P_ACTION                    IN VARCHAR2
, P_ASSIGNMENT_ID             IN NUMBER
, P_PROCESS_ID		      IN NUMBER
, P_END_DATE                  IN DATE
, P_START_DATE                IN DATE
, P_ELEMENT_ENTRY_ID          IN NUMBER
, P_TAX_CLASS                 IN VARCHAR2
, P_NO_OF_CHILDREN            IN VARCHAR2
, P_TAX_FREE_INCOME           IN VARCHAR2
, P_ADD_INCOME                IN VARCHAR2
, P_OBJECT_VERSION_NUMBER     IN NUMBER);


procedure delete_assignment
( p_process_id IN NUMBER);

function get_tax_record( p_assignment_id IN NUMBER,
                         p_date_from IN DATE) return char ;
END HR_DE_TAX_SUPPORT;


 

/
