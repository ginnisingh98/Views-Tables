--------------------------------------------------------
--  DDL for Package OE_CONTRACTS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CONTRACTS_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXUOKCS.pls 120.3.12010000.1 2008/07/25 07:56:52 appldev ship $ */


G_BSA_DOC_TYPE         CHAR(1) := 'B';  --global constant for document type of Blanket Sales Agreement.

G_SO_DOC_TYPE          CHAR(1) := 'O';  --global constant for document type of Sales Order

G_CNTR_LICENSED        CHAR(1);  /* global constant to store the result of API check OE_CONTRACTS_UTIL.check_license
                                    i.e. whether the user is licensed to use the contractual option.  */


SUBTYPE qa_result_tbl_type     IS OKC_TERMS_QA_GRP.qa_result_tbl_type;

SUBTYPE sys_var_value_tbl_type IS OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type;

SUBTYPE doc_tbl_type           IS OKC_TERMS_UTIL_GRP.doc_tbl_type;

TYPE line_var_tbl_type       IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;



/* this function is used to simply return the value of G_BSA_DOC_TYPE
  used within forms libraries to access G_BSA_DOC_TYPE as the PL/SQL implementation of
  the PL/SQL version used in forms does not allow direct reference to G_BSA_DOC_TYPE */
FUNCTION get_G_BSA_DOC_TYPE
RETURN VARCHAR2;

/* this function is used to simply return the value of G_SO_DOC_TYPE
  used within forms libraries to access G_SO_DOC_TYPE as the PL/SQL implementation of
  the PL/SQL version used in forms does not allow direct reference to G_SO_DOC_TYPE */
FUNCTION get_G_SO_DOC_TYPE
RETURN VARCHAR2;


--Check if user is licensed to use contracts
FUNCTION check_license
RETURN VARCHAR2;


--Copy Document Articles
PROCEDURE copy_articles
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_type                   IN  VARCHAR2,
   p_copy_from_doc_id           IN  NUMBER,
   p_version_number             IN  VARCHAR2 DEFAULT NULL,
   p_copy_to_doc_id             IN  NUMBER,
   p_copy_to_doc_start_date     IN  DATE     := SYSDATE,
   p_keep_version               IN  VARCHAR2 := 'N',
   p_copy_to_doc_number         IN  NUMBER DEFAULT NULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);





--Version articles of BSA or Sales Order
PROCEDURE version_articles
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_version_number             IN  VARCHAR2,
   p_clear_amendment            IN  VARCHAR2 := 'Y',

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);


--perform QA checks upon the articles belonging to a BSA
PROCEDURE qa_articles
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_qa_mode                    IN  VARCHAR2 := OKC_TERMS_QA_GRP.G_NORMAL_QA,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,

   x_qa_return_status           OUT NOCOPY VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);


--to determine whether any non standard articles exists for the BSA or Sales Order
--called from the approval workflow to determine whether non standard articles exist for the BSA or Sales Order being approved
FUNCTION non_standard_article_exists
(

   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2;


--workflow wrapper procedure for non_standard_articles_exists()
PROCEDURE WF_non_stndrd_article_exists (
                itemtype  IN VARCHAR2,
                itemkey   IN VARCHAR2,
                actid     IN NUMBER,
                funcmode  IN VARCHAR2,
                resultout OUT NOCOPY VARCHAR2);



/* During the BSA or Sales Order approval workflow process, the notification sent by workflow
   has a link that points to the attachment representing the BSA or Sales Order.
   This procedure is used by that link (by a specialized item attribute) to point
   to the OM entity or contract entity attachment representing the BSA or Sales Order */
PROCEDURE attachment_location
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,

   x_workflow_string            OUT NOCOPY VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2) ;



/* Check if Blanket or Sales Order has any terms and conditions instantiated against it i.e. if
   an article template exists for the Blanket or Sales Order or not.
   This just translates the output of the already existing procedure 'get_terms_template'
   into a 'Y' or 'N'  */
-- needed and requested by the preview print application
FUNCTION terms_exists (
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER
)
RETURN VARCHAR2;



--delete articles belonging to the BSA or Sales Order
PROCEDURE delete_articles
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);



--purge articles belonging to the BSA's or Sales Orders
PROCEDURE purge_articles
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_tbl                    IN  doc_tbl_type,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);




--this is called from the Articles QA
PROCEDURE get_article_variable_values
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_sys_var_value_tbl          IN OUT NOCOPY sys_var_value_tbl_type,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);

--this overloaded signature is called from the contract expert
PROCEDURE get_article_variable_values
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_line_var_tbl               IN  line_var_tbl_type,

   x_line_var_value_tbl         OUT NOCOPY sys_var_value_tbl_type,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);

--to return details about an article template being used by a particular BSA or Sales Order
PROCEDURE get_terms_template
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,

   x_template_id                OUT NOCOPY NUMBER,
   x_template_name              OUT NOCOPY VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);


--to return the name of a contract template
 FUNCTION Get_Template_Name(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_template_id      IN  NUMBER,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER
  ) RETURN VARCHAR2;



--to instantiate T's/C's from a Terms template to a BSA or Sales Order
PROCEDURE instantiate_terms
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_template_id                IN  NUMBER,
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_doc_start_date             IN  DATE ,
   p_doc_number                 IN  VARCHAR2,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);



--to instantiate T's/C's from a Terms template to a BSA or Sales Order when after saving the BSA/Sales Order
--the contract template id is defaulted for a new BSA or Sales Order
PROCEDURE instantiate_doc_terms
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_template_id                IN  NUMBER,
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_doc_start_date             IN  DATE ,
   p_doc_number                 IN  VARCHAR2,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);

--ETR
--This function is to check whether or not the given order has already been
--accepted (i.e signed). Returns 'Y' if accepted, and 'N' otherwise.
 FUNCTION Is_order_signed(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_id           IN  NUMBER
   ) RETURN VARCHAR2;
--ETR


--This function will be called from process order to copy terms and coditions
--from quote to order(terms instantiated on quote)
--from quote to order(terms not instantiated on quote) ,get terms from template
-- from sales order to sales order
--instantiate from template to sales order

PROCEDURE copy_doc
(
  p_api_version              IN  NUMBER,
  p_init_msg_list            IN  VARCHAR2,
  p_commit                   IN  VARCHAR2,
  p_source_doc_type          IN  VARCHAR2,
  p_source_doc_id            IN  NUMBER,
  p_target_doc_type          IN  VARCHAR2,
  p_target_doc_id            IN  NUMBER,
  p_contract_template_id     IN  NUMBER,
  x_return_status            OUT NOCOPY VARCHAR2,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2);



-- This function is a wrapper on top of oe_line_util.get_item_info
-- procedure. This is used to get the value and description for the products
-- in the blanket sales lines.
-- This will return the internal item and description for all but customer items
-- for which it returns the customer product and description
-- This function is used in the oe_blktprt_lines_v view, for the printing solution

FUNCTION GET_ITEM_INFO
(   p_item_or_desc                  IN VARCHAR2
,   p_item_identifier_type          IN VARCHAR2
,   p_inventory_item_id             IN Number
,   p_ordered_item_id               IN Number
,   p_sold_to_org_id                IN Number
,   p_ordered_item                  IN VARCHAR2
,   p_org_id                        IN Number DEFAULT NULL
) RETURN VARCHAR2;

--FP word integration

--get the default template name, source and authoring party for the template id
PROCEDURE get_contract_defaults
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_doc_type                   IN  VARCHAR2,
   p_template_id                IN  NUMBER,
   x_authoring_party            OUT NOCOPY VARCHAR2,
   x_contract_source            OUT NOCOPY VARCHAR2,
   x_template_name              OUT NOCOPY VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);

--get the template name, id, source and authoring party for the doc id
PROCEDURE get_contract_details_all
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_document_version      IN  NUMBER := NULL,
   x_template_id                OUT NOCOPY  NUMBER,
   x_authoring_party            OUT NOCOPY VARCHAR2,
   x_contract_source            OUT NOCOPY VARCHAR2,
   x_contract_source_code       OUT NOCOPY VARCHAR2,
   x_has_primary_doc            OUT NOCOPY VARCHAR2,
   x_template_name              OUT NOCOPY VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);

--check if template attached to order type is valid or not
Function Is_Terms_Template_Valid
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   p_doc_type                   IN  VARCHAR2,
   p_template_id                IN  NUMBER,
   p_org_id           		IN  NUMBER
) RETURN VARCHAR2;


--Function to check if the Authoring Party is Internal, required by Preview and Print
Function Is_Auth_Party_Internal
(
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER
 )
RETURN VARCHAR2;

Function Is_RChg_Enabled
(
   p_doc_id                     IN  NUMBER
 )
RETURN VARCHAR2;

END OE_CONTRACTS_UTIL;

/
