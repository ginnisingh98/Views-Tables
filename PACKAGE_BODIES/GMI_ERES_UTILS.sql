--------------------------------------------------------
--  DDL for Package Body GMI_ERES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_ERES_UTILS" AS
/* $Header: GMIERESB.pls 115.7 2003/10/28 15:20:52 jdiiorio noship $ */



PROCEDURE GET_ITEM_NO
 (pitem_id          IN VARCHAR2,
  pitem_no          OUT NOCOPY VARCHAR2) IS

CURSOR get_item_number IS
  SELECT item_no
  FROM   ic_item_mst
  WHERE  item_id = pitem_id;

BEGIN

  OPEN get_item_number;
  FETCH get_item_number INTO pitem_no;
  IF (get_item_number%NOTFOUND) THEN
     pitem_no := ' ';
  END IF;
  CLOSE get_item_number;

END GET_ITEM_NO;

PROCEDURE GET_ITEM_UM
 (pitem_id          IN VARCHAR2,
  pitem_um          OUT NOCOPY VARCHAR2) IS

CURSOR get_item_um IS
  SELECT item_um
  FROM   ic_item_mst
  WHERE  item_id = pitem_id;

BEGIN

  OPEN get_item_um;
  FETCH get_item_um INTO pitem_um;
  IF (get_item_um%NOTFOUND) THEN
     pitem_um := ' ';
  END IF;
  CLOSE get_item_um;


END GET_ITEM_UM;

PROCEDURE GET_ITEM_DESC
 (pitem_id          IN VARCHAR2,
  pitem_desc        OUT NOCOPY VARCHAR2) IS

CURSOR get_item_desc IS
  SELECT item_desc1
  FROM   ic_item_mst
  WHERE  item_id = pitem_id;

BEGIN

  OPEN get_item_desc;
  FETCH get_item_desc INTO pitem_desc;
  IF (get_item_desc%NOTFOUND) THEN
     pitem_desc := ' ';
  END IF;
  CLOSE get_item_desc;

END GET_ITEM_DESC;

PROCEDURE GET_UM_TYPE
 (pum               IN VARCHAR2,
  pum_type          OUT NOCOPY VARCHAR2) IS

CURSOR get_uom_type IS
  SELECT um_type
  FROM   sy_uoms_mst
  WHERE  um_code = pum;

BEGIN

  OPEN get_uom_type;
  FETCH get_uom_type INTO pum_type;
  IF (get_uom_type%NOTFOUND) THEN
     pum_type := ' ';
  END IF;
  CLOSE get_uom_type;

END GET_UM_TYPE;


PROCEDURE GET_BASE_UOM
 (pum_type          IN VARCHAR2,
  puom              OUT NOCOPY VARCHAR2) IS

CURSOR get_base_uom IS
  SELECT std_um
  FROM   sy_uoms_typ
  WHERE  um_type = pum_type;

BEGIN

  OPEN get_base_uom;
  FETCH get_base_uom INTO puom;
  IF (get_base_uom%NOTFOUND) THEN
     puom := ' ';
  END IF;
  CLOSE get_base_uom;

END GET_BASE_UOM;



PROCEDURE GET_ITEM_UOM_AND_TYPE
 (pitem_id          IN VARCHAR2,
  puom              OUT NOCOPY VARCHAR2,
  pum_type          OUT NOCOPY VARCHAR2) IS

CURSOR get_item_info IS
  SELECT m.item_um, s.um_type
  FROM   ic_item_mst m, sy_uoms_mst s
  WHERE  m.item_id = pitem_id AND
         m.item_um = s.um_code;

BEGIN

  OPEN get_item_info;
  FETCH get_item_info INTO puom, pum_type;
  IF (get_item_info%NOTFOUND) THEN
     puom := ' ';
     pum_type := ' ';
  END IF;
  CLOSE get_item_info;

END GET_ITEM_UOM_AND_TYPE;

PROCEDURE GET_LOT_NO
 (pitem_id          IN VARCHAR2,
  plot_id           IN VARCHAR2,
  plot_no           OUT NOCOPY VARCHAR2) IS

CURSOR get_lot_no IS
  SELECT lot_no
  FROM   ic_lots_mst
  WHERE  lot_id = plot_id AND
         item_id = pitem_id;

BEGIN

  OPEN get_lot_no;
  FETCH get_lot_no INTO plot_no;
  IF (get_lot_no%NOTFOUND) THEN
     plot_no := ' ';
  END IF;
  CLOSE get_lot_no;

END GET_LOT_NO;


PROCEDURE GET_SUBLOT_NO
 (pitem_id          IN VARCHAR2,
  plot_id           IN VARCHAR2,
  psublot_no        OUT NOCOPY VARCHAR2) IS

CURSOR get_sublot_no IS
  SELECT sublot_no
  FROM   ic_lots_mst
  WHERE  lot_id = plot_id AND
         item_id = pitem_id;

BEGIN

  OPEN get_sublot_no;
  FETCH get_sublot_no INTO psublot_no;
  IF (get_sublot_no%NOTFOUND) THEN
     psublot_no := ' ';
  END IF;
  CLOSE get_sublot_no;

END GET_SUBLOT_NO;


PROCEDURE GET_LOT_DESC
 (pitem_id          IN VARCHAR2,
  plot_id           IN VARCHAR2,
  plot_desc         OUT NOCOPY VARCHAR2) IS

CURSOR get_lot_desc IS
  SELECT lot_desc
  FROM   ic_lots_mst
  WHERE  lot_id = plot_id AND
         item_id = pitem_id;

BEGIN

  OPEN get_lot_desc;
  FETCH get_lot_desc INTO plot_desc;
  IF (get_lot_desc%NOTFOUND) THEN
     plot_desc := ' ';
  END IF;
  CLOSE get_lot_desc;

END GET_LOT_DESC;


PROCEDURE GET_LOOKUP_VALUE (
 plookup_type       IN VARCHAR2,
 plookup_code       IN VARCHAR2,
 pmeaning           OUT NOCOPY VARCHAR2) IS

CURSOR get_lookup IS
  SELECT meaning
  FROM fnd_lookup_values_vl
  WHERE  lookup_type = plookup_type  and
         lookup_code = plookup_code;

BEGIN

  OPEN get_lookup;
  FETCH get_lookup into pmeaning;
  IF (get_lookup%NOTFOUND) THEN
     pmeaning := ' ';
  END IF;
  CLOSE get_lookup;

END GET_LOOKUP_VALUE;


PROCEDURE GET_VENDOR_NO (
 pvendor_id         IN VARCHAR2,
 pvendor_no         OUT NOCOPY VARCHAR2) IS

CURSOR get_vend_no IS
  SELECT vendor_no
  FROM   po_vend_mst
  WHERE  vendor_id = pvendor_id;

BEGIN

  OPEN get_vend_no;
  FETCH get_vend_no INTO pvendor_no;
  IF (get_vend_no%NOTFOUND) THEN
     pvendor_no := ' ';
  END IF;
  CLOSE get_vend_no;

END GET_VENDOR_NO;

PROCEDURE GET_VENDOR_DESC (
 pvendor_id         IN VARCHAR2,
 pvendor_desc       OUT NOCOPY VARCHAR2) IS

CURSOR get_vend_name IS
  SELECT vendor_name
  FROM   po_vend_mst
  WHERE  vendor_id = pvendor_id;

BEGIN

  OPEN get_vend_name;
  FETCH get_vend_name INTO pvendor_desc;
  IF (get_vend_name%NOTFOUND) THEN
     pvendor_desc := ' ';
  END IF;
  CLOSE get_vend_name;

END GET_VENDOR_DESC;


PROCEDURE PAD_LANGUAGE (
 planguage_in       IN VARCHAR2,
 planguage_out      OUT NOCOPY VARCHAR2) IS


BEGIN
   planguage_out := RPAD(planguage_in,4);
END PAD_LANGUAGE;


PROCEDURE ACTIVATE_ITEM (pitem_id IN NUMBER) IS

BEGIN

    IF (EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS = 'SUCCESS') THEN
      UPDATE ic_item_mst_b
       SET inactive_ind = 0,
           trans_cnt = -99
       WHERE item_id = pitem_id;
      /*==================
          BUG#3103125
        ==================*/
      COMMIT;
    END IF;


END ACTIVATE_ITEM;


/*==================
    BUG#3031296
  ==================*/

PROCEDURE GET_JOURNAL_NO (
 pjournal_id        IN NUMBER,
 pjournal_no        OUT NOCOPY VARCHAR2) IS

CURSOR get_jrnl_no IS
  SELECT journal_no
  FROM   ic_jrnl_mst
  WHERE  journal_id = pjournal_id;

BEGIN
  OPEN get_jrnl_no;
  FETCH get_jrnl_no INTO pjournal_no;
  IF (get_jrnl_no%NOTFOUND) THEN
     pjournal_no := ' ';
  END IF;
  CLOSE get_jrnl_no;

END GET_JOURNAL_NO;


PROCEDURE GET_GRADE_DESC (
 pgrade             IN VARCHAR2,
 pgrade_desc        OUT NOCOPY VARCHAR2) IS

CURSOR get_grade_desc IS
  SELECT qc_grade_desc
  FROM   qc_grad_mst
  WHERE  qc_grade = pgrade;

BEGIN
  OPEN get_grade_desc;
  FETCH get_grade_desc INTO pgrade_desc;
  IF (get_grade_desc%NOTFOUND) THEN
     pgrade_desc := ' ';
  END IF;
  CLOSE get_grade_desc;

END GET_GRADE_DESC;

PROCEDURE GET_STATUS_DESC (
 pstatus            IN VARCHAR2,
 pstatus_desc       OUT NOCOPY VARCHAR2) IS


CURSOR get_status_desc IS
  SELECT status_desc
  FROM   ic_lots_sts
  WHERE  lot_status = pstatus;

BEGIN
  OPEN get_status_desc;
  FETCH get_status_desc INTO pstatus_desc;
  IF (get_status_desc%NOTFOUND) THEN
     pstatus_desc := ' ';
  END IF;
  CLOSE get_status_desc;

END GET_STATUS_DESC;


PROCEDURE GET_REASON_DESC (
 preason_code       IN VARCHAR2,
 preason_desc       OUT NOCOPY VARCHAR2) IS

CURSOR get_reason_desc IS
  SELECT reason_desc1
  FROM   sy_reas_cds
  WHERE  reason_code = preason_code;

BEGIN

  OPEN get_reason_desc;
  FETCH get_reason_desc INTO preason_desc;
  IF (get_reason_desc%NOTFOUND) THEN
     preason_desc := ' ';
  END IF;
  CLOSE get_reason_desc;


END GET_REASON_DESC;


PROCEDURE GET_WHSE_DESC (
 pwhse_code         IN VARCHAR2,
 pwhse_desc         OUT NOCOPY VARCHAR2) IS

CURSOR get_whse_desc IS
  SELECT whse_name
  FROM   ic_whse_mst
  WHERE  whse_code = pwhse_code;

BEGIN

  OPEN get_whse_desc;
  FETCH get_whse_desc INTO pwhse_desc;
  IF (get_whse_desc%NOTFOUND) THEN
     pwhse_desc := ' ';
  END IF;
  CLOSE get_whse_desc;


END GET_WHSE_DESC;


PROCEDURE GET_JRNL_COMMENT (
 pjournal_id        IN NUMBER,
 pjrnl_comment      OUT NOCOPY VARCHAR2) IS

CURSOR get_jrnl_comment IS
  SELECT journal_comment
  FROM   ic_jrnl_mst
  WHERE  journal_id = pjournal_id;

BEGIN
  OPEN get_jrnl_comment;
  FETCH get_jrnl_comment INTO pjrnl_comment;
  IF (get_jrnl_comment%NOTFOUND) THEN
     pjrnl_comment := ' ';
  END IF;
  CLOSE get_jrnl_comment;

END GET_JRNL_COMMENT;


PROCEDURE GET_SEG_VALUE (pcategory_id        IN NUMBER,
                         pstructure_id       IN NUMBER,
                         pcolname            IN VARCHAR2,
                         pvalue              OUT NOCOPY VARCHAR2)

IS

CURSOR get_value is
  SELECT *
  FROM   mtl_categories
  WHERE  structure_id = pstructure_id
  AND    category_id = pcategory_id;

x_cat_rec     get_value%ROWTYPE;

BEGIN

 IF (pcolname IS NULL) THEN
     pvalue := NULL;
     RETURN;
 END IF;

 OPEN get_value;
 FETCH get_value into x_cat_rec;
 CLOSE get_value;

 IF (pcolname = 'SEGMENT1') THEN
     pvalue := x_cat_rec.segment1;
 ELSIF (pcolname = 'SEGMENT2') THEN
     pvalue := x_cat_rec.segment2;
 ELSIF (pcolname = 'SEGMENT3') THEN
     pvalue := x_cat_rec.segment3;
 ELSIF (pcolname = 'SEGMENT4') THEN
     pvalue := x_cat_rec.segment4;
 ELSIF (pcolname = 'SEGMENT5') THEN
     pvalue := x_cat_rec.segment5;
 ELSIF (pcolname = 'SEGMENT6') THEN
     pvalue := x_cat_rec.segment6;
 ELSIF (pcolname = 'SEGMENT7') THEN
     pvalue := x_cat_rec.segment7;
 ELSIF (pcolname = 'SEGMENT8') THEN
     pvalue := x_cat_rec.segment8;
 ELSIF (pcolname = 'SEGMENT9') THEN
     pvalue := x_cat_rec.segment9;
 ELSIF (pcolname = 'SEGMENT10') THEN
     pvalue := x_cat_rec.segment10;
 ELSIF (pcolname = 'SEGMENT11') THEN
     pvalue := x_cat_rec.segment11;
 ELSIF (pcolname = 'SEGMENT12') THEN
     pvalue := x_cat_rec.segment12;
 ELSIF (pcolname = 'SEGMENT13') THEN
     pvalue := x_cat_rec.segment13;
 ELSIF (pcolname = 'SEGMENT14') THEN
     pvalue := x_cat_rec.segment14;
 ELSIF (pcolname = 'SEGMENT15') THEN
     pvalue := x_cat_rec.segment15;
 ELSIF (pcolname = 'SEGMENT16') THEN
     pvalue := x_cat_rec.segment16;
 ELSIF (pcolname = 'SEGMENT17') THEN
     pvalue := x_cat_rec.segment17;
 ELSIF (pcolname = 'SEGMENT18') THEN
     pvalue := x_cat_rec.segment18;
 ELSIF (pcolname = 'SEGMENT19') THEN
     pvalue := x_cat_rec.segment19;
 ELSIF (pcolname = 'SEGMENT20') THEN
     pvalue := x_cat_rec.segment20;
 ELSE
     pvalue := NULL;
 END IF;

END GET_SEG_VALUE;

PROCEDURE GET_ATTRIBUTE_VALUE (pitem_id      IN NUMBER,
                               pcolname      IN VARCHAR2,
                               pvalue        OUT NOCOPY VARCHAR2)

IS

CURSOR get_itemattr is
  SELECT *
  FROM   ic_item_mst_b
  WHERE  item_id = pitem_id;

x_item_rec     get_itemattr%ROWTYPE;

BEGIN

 IF (pcolname IS NULL) THEN
     pvalue := NULL;
     RETURN;
 END IF;

 OPEN get_itemattr;
 FETCH get_itemattr into x_item_rec;
 CLOSE get_itemattr;


 IF (pcolname = 'ATTRIBUTE1') THEN
     pvalue := x_item_rec.attribute1;
 ELSIF (pcolname = 'ATTRIBUTE2') THEN
     pvalue := x_item_rec.attribute2;
 ELSIF (pcolname = 'ATTRIBUTE3') THEN
     pvalue := x_item_rec.attribute3;
 ELSIF (pcolname = 'ATTRIBUTE4') THEN
     pvalue := x_item_rec.attribute4;
 ELSIF (pcolname = 'ATTRIBUTE5') THEN
     pvalue := x_item_rec.attribute5;
 ELSIF (pcolname = 'ATTRIBUTE6') THEN
     pvalue := x_item_rec.attribute6;
 ELSIF (pcolname = 'ATTRIBUTE7') THEN
     pvalue := x_item_rec.attribute7;
 ELSIF (pcolname = 'ATTRIBUTE8') THEN
     pvalue := x_item_rec.attribute8;
 ELSIF (pcolname = 'ATTRIBUTE9') THEN
     pvalue := x_item_rec.attribute9;
 ELSIF (pcolname = 'ATTRIBUTE10') THEN
     pvalue := x_item_rec.attribute10;
 ELSIF (pcolname = 'ATTRIBUTE11') THEN
     pvalue := x_item_rec.attribute11;
 ELSIF (pcolname = 'ATTRIBUTE12') THEN
     pvalue := x_item_rec.attribute12;
 ELSIF (pcolname = 'ATTRIBUTE13') THEN
     pvalue := x_item_rec.attribute13;
 ELSIF (pcolname = 'ATTRIBUTE14') THEN
     pvalue := x_item_rec.attribute14;
 ELSIF (pcolname = 'ATTRIBUTE15') THEN
     pvalue := x_item_rec.attribute15;
 ELSIF (pcolname = 'ATTRIBUTE16') THEN
     pvalue := x_item_rec.attribute16;
 ELSIF (pcolname = 'ATTRIBUTE17') THEN
     pvalue := x_item_rec.attribute17;
 ELSIF (pcolname = 'ATTRIBUTE18') THEN
     pvalue := x_item_rec.attribute18;
 ELSIF (pcolname = 'ATTRIBUTE19') THEN
     pvalue := x_item_rec.attribute19;
 ELSIF (pcolname = 'ATTRIBUTE20') THEN
     pvalue := x_item_rec.attribute20;
 ELSIF (pcolname = 'ATTRIBUTE21') THEN
     pvalue := x_item_rec.attribute21;
 ELSIF (pcolname = 'ATTRIBUTE22') THEN
     pvalue := x_item_rec.attribute22;
 ELSIF (pcolname = 'ATTRIBUTE23') THEN
     pvalue := x_item_rec.attribute23;
 ELSIF (pcolname = 'ATTRIBUTE24') THEN
     pvalue := x_item_rec.attribute24;
 ELSIF (pcolname = 'ATTRIBUTE25') THEN
     pvalue := x_item_rec.attribute25;
 ELSIF (pcolname = 'ATTRIBUTE26') THEN
     pvalue := x_item_rec.attribute26;
 ELSIF (pcolname = 'ATTRIBUTE27') THEN
     pvalue := x_item_rec.attribute27;
 ELSIF (pcolname = 'ATTRIBUTE28') THEN
     pvalue := x_item_rec.attribute28;
 ELSIF (pcolname = 'ATTRIBUTE29') THEN
     pvalue := x_item_rec.attribute29;
 ELSIF (pcolname = 'ATTRIBUTE30') THEN
     pvalue := x_item_rec.attribute30;
 ELSE
     pvalue := NULL;
 END IF;



END GET_ATTRIBUTE_VALUE;


PROCEDURE GET_BATCH_NO
 (pbatch_id         IN NUMBER,
  pbatch_no         OUT NOCOPY VARCHAR2) IS

CURSOR get_batch_no  IS
  SELECT batch_no
  FROM   gme_batch_header
  WHERE  batch_id = pbatch_id;

BEGIN

  OPEN get_batch_no;
  FETCH get_batch_no INTO pbatch_no;
  IF (get_batch_no%NOTFOUND) THEN
     pbatch_no := ' ';
  END IF;
  CLOSE get_batch_no;

END GET_BATCH_NO;

PROCEDURE GET_HOLD_RELEASE_DATE
 (pitem_id         IN NUMBER,
  plot_id          IN NUMBER,
  phold_date       OUT NOCOPY DATE) IS

CURSOR get_hold_date IS
  SELECT ic_hold_date
  FROM   ic_lots_cpg
  WHERE  item_id = pitem_id
  AND    lot_id = plot_id;

BEGIN
  OPEN get_hold_date;
  FETCH get_hold_date INTO phold_date;
  IF (get_hold_date%NOTFOUND) THEN
     phold_date := NULL;
  END IF;
  CLOSE get_hold_date;


END GET_HOLD_RELEASE_DATE;


END gmi_eres_utils;

/
