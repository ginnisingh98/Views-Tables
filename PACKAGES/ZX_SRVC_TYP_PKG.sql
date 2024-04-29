--------------------------------------------------------
--  DDL for Package ZX_SRVC_TYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_SRVC_TYP_PKG" AUTHID CURRENT_USER AS
/* $Header: zxifsrvctypspkgs.pls 120.28.12010000.3 2009/03/11 11:36:29 tsen ship $ */

/* ======================================================================*
 | Data Type Definitions                                                 |
 * ======================================================================*/
TYPE VARCHAR2_1_tbl_type is TABLE OF VARCHAR2(1)
INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_2_tbl_type is TABLE OF VARCHAR2(2)
INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_30_tbl_type is TABLE OF VARCHAR2(30)
INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_50_tbl_type is TABLE OF VARCHAR2(50)
INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_240_tbl_type is TABLE OF VARCHAR2(240)
INDEX BY BINARY_INTEGER;

TYPE NUMBER_tbl_type  IS TABLE OF NUMBER(15)
INDEX BY BINARY_INTEGER;

TYPE NUMBER_tbl_type_1 IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

 -- Bug 7519403 -- Added the following declaration. commented the same in pkg body
 TYPE l_line_level_rec_type IS RECORD(
     trx_id                     NUMBER);

 TYPE l_line_level_tbl_type IS TABLE OF l_line_level_rec_type INDEX BY BINARY_INTEGER;
 l_line_level_tbl l_line_level_tbl_type;

 -- Bug 8265004
 TYPE l_line_level_rec_type1 IS RECORD(
     trx_id                     NUMBER);

 TYPE l_line_level_tbl_type1 IS TABLE OF l_line_level_rec_type1 INDEX BY BINARY_INTEGER;
 l_line_level_tbl1 l_line_level_tbl_type1;

/*-----------------------------------------------------------------------*
 |   PUBLIC  FUNCTIONS/PROCEDURES                                        |
 *-----------------------------------------------------------------------*/



/* ======================================================================*
 | PROCEDURE Calculate_Tax : Called from published service               |
 |                           calculate_tax                               |
 * ======================================================================*/
  PROCEDURE Calculate_Tax(
    p_event_class_rec      IN  OUT NOCOPY zx_api_pub.event_class_rec_type,
    x_return_status        OUT NOCOPY VARCHAR2
    );



/* ======================================================================*
 | PROCEDURE Import : Called from published service                      |
 |                    import_document_with_tax                           |
 * ======================================================================*/
  PROCEDURE Import(
    p_event_class_rec        IN   OUT NOCOPY  zx_api_pub.event_class_rec_type,
    x_return_status          OUT  NOCOPY VARCHAR2
    );


/* ======================================================================*
 | PROCEDURE Override_Tax_Lines  : Called from published service         |
 |                                 override_tax                          |
 * ======================================================================*/
  PROCEDURE Override_Tax_Lines(
    p_event_class_rec        IN  OUT NOCOPY zx_api_pub.event_class_rec_type,
    p_override_level         IN  VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2
    );


    /* ======================================================================*
 | PROCEDURE Document_Level_Changes : Called from published service      |
 |                                    global_document_update             |
 * ======================================================================*/
  PROCEDURE Document_Level_Changes(
    x_return_status          OUT NOCOPY VARCHAR2,
    p_event_class_rec        IN  zx_api_pub.event_class_rec_type,
    p_tax_hold_released_code IN  zx_api_pub.validation_status_tbl_type
    );

/* ======================================================================*
 | PROCEDURE Mark_Tax_Lines_Deleted : Called from published service      |
 |                                    mark_tax_lines_deleted             |
 * ======================================================================*/
  PROCEDURE mark_tax_lines_deleted(
    p_trx_line_rec            IN ZX_API_PUB.TRANSACTION_LINE_REC_TYPE ,
    x_return_status           OUT NOCOPY VARCHAR2
    );

 /* ======================================================================*
 | PROCEDURE Reverse_Document : Called from published service            |
 |                              reverse_document                         |
 * ======================================================================*/
  PROCEDURE reverse_document(
    p_event_class_rec         IN  ZX_API_PUB.event_class_rec_type,
    x_return_status           OUT NOCOPY VARCHAR2
    );


 /* ======================================================================*
 | PROCEDURE Reverse_distributions : Called from published service       |
 |                                   reverse_distributions               |
 * ======================================================================*/
  PROCEDURE Reverse_Distributions(
    x_return_status            OUT NOCOPY VARCHAR2
    );



/* ======================================================================*
 | PROCEDURE Determine_Recovery : Called from published service          |
 |                               determine_recovery                      |
 * ======================================================================*/
  PROCEDURE Determine_Recovery(
    p_event_class_rec          IN  zx_api_pub.event_class_rec_type,
    x_return_status            OUT NOCOPY VARCHAR2
    );


/* ======================================================================*
 | PROCEDURE Override_Recovery : Called from published service           |
 |                               override_recovery                       |
 * ======================================================================*/
  PROCEDURE Override_Recovery(
    p_event_class_rec          IN  zx_api_pub.event_class_rec_type,
    x_return_status            OUT NOCOPY VARCHAR2
    );


/* ======================================================================*
 | PROCEDURE Freeze_Distribution_Lines : Called from published service   |
 |                              freeze_distribution_lines                |
 * ======================================================================*/
  PROCEDURE Freeze_Distribution_Lines(
    p_event_class_rec         IN  zx_api_pub.event_class_rec_type,
    x_return_status           OUT NOCOPY VARCHAR2
    );



/* ======================================================================*
 | PROCEDURE Validate_Document_for_Tax : Called from published service   |
 |                              validate_document_for_tax                |
 * ======================================================================*/
  PROCEDURE Validate_Document_for_Tax(
    p_trx_rec                 IN  zx_api_pub.transaction_rec_type,
    p_event_class_rec         IN  zx_api_pub.event_class_rec_type,
    x_validation_status       OUT NOCOPY VARCHAR2,
    x_hold_status_code        OUT NOCOPY zx_api_pub.hold_codes_tbl_type,
    x_return_status           OUT NOCOPY VARCHAR2
    );


/* ======================================================================*
 | PROCEDURE Discard_Tax_only_lines: Called from published service       |
 |                                   discard_tax_only_lines              |
 * ======================================================================*/
  PROCEDURE Discard_Tax_only_lines(
    p_event_class_rec          IN  zx_api_pub.event_class_rec_type ,
    x_return_status            OUT NOCOPY VARCHAR2
    );

/* ======================================================================*
 | PROCEDURE synchronize_tax       : Called from published service       |
 |                                   synchronize_tax_repository          |
 * ======================================================================*/
  PROCEDURE synchronize_tax(
    p_event_class_rec          IN  zx_api_pub.event_class_rec_type ,
    x_return_status            OUT NOCOPY VARCHAR2
    );

/* ======================================================================*
 | PROCEDURE insupd_line_det_factors: Called from published service      |
 |                                   insert_line_det_factors/            |
 |                                    update_line_det_factors            |
 * ======================================================================*/

   PROCEDURE insupd_line_det_factors(
     p_event_class_rec          IN  OUT NOCOPY zx_api_pub.event_class_rec_type ,
     x_return_status            OUT NOCOPY VARCHAR2
     );

/* =============================================================================*
 | PROCEDURE zx_lines_table_handler: Handles inserts/updates/deletes to zx_lines|
 * ============================================================================*/
  PROCEDURE zx_lines_table_handler
  (
   p_event_class_rec          IN  ZX_API_PUB.event_class_rec_type ,
   p_event                    IN  VARCHAR2,
   p_tax_regime_code          IN  VARCHAR2,
   p_provider_id              IN  NUMBER,
   x_return_status            OUT NOCOPY VARCHAR2
  );

/* ===========================================================================*
 | PROCEDURE Get_Tax_Profile_Ids : Populates party tax profile ids            |
 * ===========================================================================*/
  PROCEDURE Get_Tax_Profile_Ids
  (
    x_return_status    OUT NOCOPY  VARCHAR2,
    p_party_type_Code  IN          VARCHAR2,
    p_party_id         IN          NUMBER,
    p_party_loc_id     IN          NUMBER,
    p_party_site_id    IN          NUMBER,
    x_tax_prof_id      OUT NOCOPY  NUMBER
  );


/* ===========================================================================*
 | PROCEDURE Default_tax_attrs_wrapper : Overloaded procedure acts as a wrapper|
 | to default_tax_attribs procedure to default the tax determining attributes. |
 * ===========================================================================*/

  PROCEDURE default_tax_attrs_wrapper
  (
   p_trx_line_index   IN             NUMBER,
   p_event_class_rec  IN             ZX_API_PUB.event_class_rec_type,
   x_return_status    OUT NOCOPY     VARCHAR2
  ) ;


/* =========================================================================*
 | PROCEDURE get_default_tax_det_attribs : Overloaded procedure that accepts|
 | inputs in GTT, calls the redefaulting APIs and updates the determining   |
 | attributes back to GTT                                                   |
 * ========================================================================*/

  PROCEDURE get_default_tax_det_attrs
  (
   p_event_class_rec  IN             ZX_API_PUB.event_class_rec_type,
   x_return_status    OUT NOCOPY     VARCHAR2
  ) ;

/* =========================================================================*
 | PROCEDURE decide_call_redefault_APIs : Determine if there is a need to   |
 | default/redefault the tax determining attributes                         |
 * ========================================================================*/
FUNCTION decide_call_redefault_APIs
  (
   p_trx_line_index  IN             BINARY_INTEGER
  ) RETURN BOOLEAN ;

/* =========================================================================*
 | PROCEDURE call_redefaulting_APIs : Calls the redefaulting APIs in case of|
 | UPDATE line level action                                                 |
 * ========================================================================*/
PROCEDURE call_redefaulting_APIs
  (p_event_class_rec IN             ZX_API_PUB.event_class_rec_type,
   p_trx_line_index  IN             BINARY_INTEGER,
   x_return_status   OUT    NOCOPY  VARCHAR2
  );


END ZX_SRVC_TYP_PKG;


/
