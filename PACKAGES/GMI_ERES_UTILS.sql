--------------------------------------------------------
--  DDL for Package GMI_ERES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_ERES_UTILS" AUTHID CURRENT_USER AS
/* $Header: GMIERESS.pls 115.5 2003/10/22 13:30:06 jdiiorio noship $ */

PROCEDURE GET_ITEM_NO (
 pitem_id          IN VARCHAR2,
 pitem_no          OUT NOCOPY VARCHAR2);

PROCEDURE GET_ITEM_UM(
 pitem_id          IN VARCHAR2,
 pitem_um          OUT NOCOPY VARCHAR2);

PROCEDURE GET_ITEM_DESC(
 pitem_id          IN VARCHAR2,
 pitem_desc        OUT NOCOPY VARCHAR2);

PROCEDURE GET_UM_TYPE(
 pum               IN VARCHAR2,
 pum_type          OUT NOCOPY VARCHAR2);

PROCEDURE GET_BASE_UOM (
 pum_type          IN VARCHAR2,
 puom              OUT NOCOPY VARCHAR2);

PROCEDURE GET_ITEM_UOM_AND_TYPE (
 pitem_id          IN VARCHAR2,
 puom              OUT NOCOPY VARCHAR2,
 pum_type          OUT NOCOPY VARCHAR2);

PROCEDURE GET_LOT_NO (
 pitem_id          IN VARCHAR2,
 plot_id           IN VARCHAR2,
 plot_no           OUT NOCOPY VARCHAR2);

PROCEDURE GET_SUBLOT_NO (
 pitem_id          IN VARCHAR2,
 plot_id           IN VARCHAR2,
 psublot_no        OUT NOCOPY VARCHAR2);

PROCEDURE GET_LOT_DESC (
 pitem_id          IN VARCHAR2,
 plot_id           IN VARCHAR2,
 plot_desc         OUT NOCOPY VARCHAR2);

PROCEDURE GET_LOOKUP_VALUE (
 plookup_type       IN VARCHAR2,
 plookup_code       IN VARCHAR2,
 pmeaning           OUT NOCOPY VARCHAR2);

PROCEDURE GET_VENDOR_NO (
 pvendor_id         IN VARCHAR2,
 pvendor_no         OUT NOCOPY VARCHAR2);

PROCEDURE GET_VENDOR_DESC (
 pvendor_id         IN VARCHAR2,
 pvendor_desc       OUT NOCOPY VARCHAR2);

PROCEDURE PAD_LANGUAGE (
 planguage_in       IN VARCHAR2,
 planguage_out      OUT NOCOPY VARCHAR2);

PROCEDURE ACTIVATE_ITEM (
 pitem_id           IN NUMBER);

/*===============================================
   BUG#3031296 - Added for Mass Transactions form.
  ===============================================*/

PROCEDURE GET_JOURNAL_NO (
 pjournal_id        IN NUMBER,
 pjournal_no        OUT NOCOPY VARCHAR2);

PROCEDURE GET_GRADE_DESC (
 pgrade             IN VARCHAR2,
 pgrade_desc        OUT NOCOPY VARCHAR2);

PROCEDURE GET_STATUS_DESC (
 pstatus            IN VARCHAR2,
 pstatus_desc       OUT NOCOPY VARCHAR2);

PROCEDURE GET_REASON_DESC (
 preason_code       IN VARCHAR2,
 preason_desc       OUT NOCOPY VARCHAR2);

PROCEDURE GET_WHSE_DESC (
 pwhse_code         IN VARCHAR2,
 pwhse_desc         OUT NOCOPY VARCHAR2);

PROCEDURE GET_JRNL_COMMENT (
 pjournal_id        IN NUMBER,
 pjrnl_comment      OUT NOCOPY VARCHAR2);

/*===============================================
   Added for Item Master Classes/Flexfields.
  ===============================================*/

PROCEDURE GET_SEG_VALUE (pcategory_id        IN NUMBER,
                     pstructure_id           IN NUMBER,
                     pcolname                IN VARCHAR2,
                     pvalue                  OUT NOCOPY VARCHAR2);

PROCEDURE GET_ATTRIBUTE_VALUE (pitem_id      IN NUMBER,
                         pcolname            IN VARCHAR2,
                         pvalue              OUT NOCOPY VARCHAR2);

/*===============================================
   Added for Lot Conversion for Batches
  ===============================================*/

PROCEDURE GET_BATCH_NO (pbatch_id        IN NUMBER,
                        pbatch_no        OUT NOCOPY VARCHAR2);


/*===============================================
   Added for PPT Project.
  ===============================================*/

PROCEDURE GET_HOLD_RELEASE_DATE (pitem_id         IN NUMBER,
                                 plot_id          IN NUMBER,
                                 phold_date       OUT NOCOPY DATE);


END gmi_eres_utils;

 

/
