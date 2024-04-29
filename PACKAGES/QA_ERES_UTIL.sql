--------------------------------------------------------
--  DDL for Package QA_ERES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_ERES_UTIL" AUTHID CURRENT_USER AS
/* $Header: qaedruts.pls 120.3.12010000.1 2008/07/25 09:19:27 appldev ship $ */


  -- This procedure takes in occurrence, collection_id and
  -- plan_id of the Child Plan Result and gives out the
  -- occurrence, collection_id and plan_id of the topmost
  -- parent results record.  .

  PROCEDURE find_topmost_parent
              (p_child_occ       IN  NUMBER,
               p_child_coll_id   IN  NUMBER,
               p_child_plan_id   IN  NUMBER,
               p_parent_occ      OUT NOCOPY NUMBER,
               p_parent_coll_id  OUT NOCOPY NUMBER,
               p_parent_plan_id  OUT NOCOPY NUMBER
              );

  -- This function takes in the occurrence, collection_id,
  -- plan_id and char_id of the eSignature Status collection
  -- element and returns the value in QA_RESULTS for the
  -- eSignature Status element.

   FUNCTION get_result_esig_status (p_occurrence IN NUMBER,
                                    p_coll_id    IN NUMBER,
                                    p_plan_id    IN NUMBER,
                                    p_char_id    IN NUMBER)
   RETURN VARCHAR2;


   -- This function returns the meaning from mfg_lookups
   -- given the lookup_code and lookup_type.

   FUNCTION get_mfg_lookups_meaning (p_lookup_type IN VARCHAR2,
                                     p_lookup_code IN NUMBER)
   RETURN VARCHAR2;

   -- R12 ERES Support in Service Family. Bug 4345768
   -- START
   -- This function returns if a given plan is
   -- enabled for deferred eSignatures. Returns Y or N

   FUNCTION is_def_sig_enabled (p_plan_id IN NUMBER)
   RETURN VARCHAR2;

   -- This procedure enables a given collection plan for Deferred
   -- Esignatures by adding the 'eSignature Status' element to the plan.
   PROCEDURE add_esig_status ( p_plan_id IN NUMBER );

   -- END
   -- R12 ERES Support in Service Family. Bug 4345768

   -- Bug 4502450. R12 Esig Status support in Multirow UQR
   -- saugupta Wed, 24 Aug 2005 08:37:40 -0700 PDT

   -- For a row in a plan Function return T if eSign
   -- Status is PENDING else returns F

   FUNCTION is_esig_status_pending(p_plan_id IN NUMBER,
                                   p_collection_id IN NUMBER,
                                   p_occurrence IN NUMBER) RETURN VARCHAR2;

   -- R12.1 MES ERES Integration with Quality Start
   -- This procedure takes in the collection id for a transaction
   -- and generates the XML CLOB object for that transaction.
   PROCEDURE generate_xml(p_collection_id IN varchar2,
                          x_xml_result OUT NOCOPY CLOB);

   -- This procedure takes in the collection id, plan_id
   -- and generates the XML CLOB object for that plan in the transaction
   PROCEDURE generate_xml_for_plan(p_collection_id IN varchar2,
                                   p_plan_id IN varchar2,
                                   x_xml_result_plan OUT NOCOPY CLOB);

   -- This procedure generates the XML CLOB object for for a particular
   -- result row identified by plan_id, collection_id and occurrence
   PROCEDURE get_xml_for_row(p_document_id IN varchar2,
                             x_xml_result_row OUT NOCOPY CLOB);
   -- R12.1 MES ERES Integration with Quality Start

END QA_ERES_UTIL;


/
