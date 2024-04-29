--------------------------------------------------------
--  DDL for Package OKC_CODE_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CODE_HOOK" AUTHID CURRENT_USER AS
/* $Header: OKCCCHKS.pls 120.0.12010000.15 2013/08/26 08:38:23 serukull noship $ */

/* PROCEDURE
 GET_MULTIVAL_UDV_FOR_XPRT    This routine is used to get the multiple values for variables in expert.

INPUT PARAMETERS

p_doc_type   Document Type of Contract(eg: PO_STANDARD)
p_doc_id     Document_id of contract.


RETURN VALUE
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_udf_var_tbl_value        table which return variable-code and variable value of every variable. If multi values are to be returned for

*/
 PROCEDURE GET_MULTIVAL_UDV_FOR_XPRT
 ( p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2,
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_udf_var_code               IN  VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_cust_udf_var_mul_val_tbl        OUT NOCOPY OKC_XPRT_XRULE_VALUES_PVT.udf_var_value_tbl_type,
   x_hook_used                  OUT NOCOPY NUMBER
 );


/* PROCEDURE
 GET_XPRT_CLAUSE_ORDER    This routine is used to get the column on which the clauses have to be ordered after the Contract Expert is run

INPUT PARAMETERS

None


RETURN VALUE
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_order_by_column            Column on which the clauses have to be ordered


*/
 PROCEDURE GET_XPRT_CLAUSE_ORDER
 ( x_return_status             IN OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_order_by_column            OUT NOCOPY VARCHAR2,
   x_hook_used                  OUT NOCOPY NUMBER
 );


/* FUNCTION
 IS_NOT_PROVISIONAL_SECTION    This routine is used to find out if a section is a provisional section or not
If it returns true, then it is not a provisional section.
Or else, it is a provisional section
INPUT PARAMETERS

None


RETURN VALUE
   p_section_heading            IN  VARCHAR2,            Section that has to be checked if it is a provisional section or not
*/


 FUNCTION IS_NOT_PROVISIONAL_SECTION
 (
   p_section_heading   IN  VARCHAR2
  ,p_source_doc_type   IN  VARCHAR2 default null
  ,p_source_doc_id     IN NUMBER default null
 ) RETURN VARCHAR2;

/* FUNCTION
 IS_NEW_KFF_ITEM_SEG_ENABLED    This routine is used to decide on whether the new Item KFF segment setup should be considered during Contract Expert rule execution.
INPUT PARAMETERS
None

RETURN VALUE
BOOLEAN : TRUE if the new item seg setup is enabled, FALSE otherwise
*/


 FUNCTION IS_NEW_KFF_ITEM_SEG_ENABLED
 RETURN BOOLEAN;


 /*
  * Enable this procedure when you are using Mandatory and RWA columns on Rule Outcomes
  * and you want these flags to be synced with the document.
  *
  * Added by serukull
  *
  */

  PROCEDURE sync_rwa_with_document
  (p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2,
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_article_id_tbl             IN  okc_terms_multirec_grp.article_id_tbl_type,
   x_return_status              IN  OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
  );


  type l_qa_errors_table is table of OKC_QA_ERRORS_T%ROWTYPE INDEX BY BINARY_INTEGER;


 /*
  * Enable this procedure if custom QA checks has to be added for the Contract Expert Rules Activation
  * Parameters  : INPUT : p_rule_id - Rule corresponding to which the QA check will be run
  *                       p_sequence_id - for future use. No significant need of using this parameter as of now
  *               OUTPUT: x_hook_used - 0 - not used
  *                                     1 - used
  *                       x_qa_errors_tbl - This table should be populated with the QA check message details.
  *                       More than one QA check can be written in this package and in this case, one row has to be entered in this table for each QA check message.
  */


  PROCEDURE rules_qa_check
       (
        p_rule_id		     IN NUMBER,
        p_sequence_id	   IN NUMBER,
		    x_hook_used      OUT NOCOPY NUMBER,
		    x_qa_errors_tbl  OUT NOCOPY l_qa_errors_table,
        x_return_status  OUT  NOCOPY VARCHAR2,
        x_msg_count      OUT NOCOPY NUMBER,
        x_msg_data       OUT NOCOPY VARCHAR2
       );

  TYPE cont_art_sort IS RECORD (
      id                        OKC_K_ARTICLES_B.id%type,
      scn_id                    OKC_K_ARTICLES_B.scn_id%type
    );

  TYPE cont_art_sort_tbl IS TABLE OF cont_art_sort;

	PROCEDURE sort_clauses(
		p_doc_type                     IN  VARCHAR2,
		p_doc_id                       IN  NUMBER,
		x_return_status                OUT NOCOPY VARCHAR2,
		x_msg_count                    OUT NOCOPY NUMBER,
		x_msg_data                     OUT NOCOPY VARCHAR2,
		x_cont_art_tbl                 OUT NOCOPY cont_art_sort_tbl
		);


END okc_code_hook;


/
