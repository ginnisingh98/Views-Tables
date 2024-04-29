--------------------------------------------------------
--  DDL for Package Body CSI_PRICING_ATTRIBS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_PRICING_ATTRIBS_PVT" AS
/* $Header: csivpab.pls 120.0 2005/05/24 17:47:28 appldev noship $ */

g_pkg_name      CONSTANT VARCHAR2(30) := 'csi_pricing_attribs_pvt';
g_expire_pric_flag       VARCHAR2(1) := 'N';


/*----------------------------------------------------------*/
/* Procedure name:  Initialize_ou_rec_no_dump               */
/* Description : This gets the first record from history    */
/*                                                          */
/*----------------------------------------------------------*/

PROCEDURE Initialize_pri_rec_no_dump
(
 x_pri_rec              IN OUT NOCOPY  csi_datastructures_pub.pricing_attribs_rec,
 p_pri_hist_id          IN      NUMBER,
 x_first_no_dump        IN OUT NOCOPY  DATE
) IS

  CURSOR Int_no_dump(p_pri_hist_id IN NUMBER ) IS
  SELECT    creation_date,
            new_PRICING_CONTEXT,
            new_PRICING_ATTRIBUTE1,
            new_PRICING_ATTRIBUTE2,
            new_PRICING_ATTRIBUTE3,
            new_PRICING_ATTRIBUTE4,
            new_PRICING_ATTRIBUTE5,
            new_PRICING_ATTRIBUTE6,
            new_PRICING_ATTRIBUTE7,
            new_PRICING_ATTRIBUTE8,
            new_PRICING_ATTRIBUTE9,
            new_PRICING_ATTRIBUTE10,
            new_PRICING_ATTRIBUTE11,
            new_PRICING_ATTRIBUTE12,
            new_PRICING_ATTRIBUTE13,
            new_PRICING_ATTRIBUTE14,
            new_PRICING_ATTRIBUTE15,
            new_PRICING_ATTRIBUTE16,
            new_PRICING_ATTRIBUTE17,
            new_PRICING_ATTRIBUTE18,
            new_PRICING_ATTRIBUTE19,
            new_PRICING_ATTRIBUTE20,
            new_PRICING_ATTRIBUTE21,
            new_PRICING_ATTRIBUTE22,
            new_PRICING_ATTRIBUTE23,
            new_PRICING_ATTRIBUTE24,
            new_PRICING_ATTRIBUTE25,
            new_PRICING_ATTRIBUTE26,
            new_PRICING_ATTRIBUTE27,
            new_PRICING_ATTRIBUTE28,
            new_PRICING_ATTRIBUTE29,
            new_PRICING_ATTRIBUTE30,
            new_PRICING_ATTRIBUTE31,
            new_PRICING_ATTRIBUTE32,
            new_PRICING_ATTRIBUTE33,
            new_PRICING_ATTRIBUTE34,
            new_PRICING_ATTRIBUTE35,
            new_PRICING_ATTRIBUTE36,
            new_PRICING_ATTRIBUTE37,
            new_PRICING_ATTRIBUTE38,
            new_PRICING_ATTRIBUTE39,
            new_PRICING_ATTRIBUTE40,
            new_PRICING_ATTRIBUTE41,
            new_PRICING_ATTRIBUTE42,
            new_PRICING_ATTRIBUTE43,
            new_PRICING_ATTRIBUTE44,
            new_PRICING_ATTRIBUTE45,
            new_PRICING_ATTRIBUTE46,
            new_PRICING_ATTRIBUTE47,
            new_PRICING_ATTRIBUTE48,
            new_PRICING_ATTRIBUTE49,
            new_PRICING_ATTRIBUTE50,
            new_PRICING_ATTRIBUTE51,
            new_PRICING_ATTRIBUTE52,
            new_PRICING_ATTRIBUTE53,
            new_PRICING_ATTRIBUTE54,
            new_PRICING_ATTRIBUTE55,
            new_PRICING_ATTRIBUTE56,
            new_PRICING_ATTRIBUTE57,
            new_PRICING_ATTRIBUTE58,
            new_PRICING_ATTRIBUTE59,
            new_PRICING_ATTRIBUTE60,
            new_PRICING_ATTRIBUTE61,
            new_PRICING_ATTRIBUTE62,
            new_PRICING_ATTRIBUTE63,
            new_PRICING_ATTRIBUTE64,
            new_PRICING_ATTRIBUTE65,
            new_PRICING_ATTRIBUTE66,
            new_PRICING_ATTRIBUTE67,
            new_PRICING_ATTRIBUTE68,
            new_PRICING_ATTRIBUTE69,
            new_PRICING_ATTRIBUTE70,
            new_PRICING_ATTRIBUTE71,
            new_PRICING_ATTRIBUTE72,
            new_PRICING_ATTRIBUTE73,
            new_PRICING_ATTRIBUTE74,
            new_PRICING_ATTRIBUTE75,
            new_PRICING_ATTRIBUTE76,
            new_PRICING_ATTRIBUTE77,
            new_PRICING_ATTRIBUTE78,
            new_PRICING_ATTRIBUTE79,
            new_PRICING_ATTRIBUTE80,
            new_PRICING_ATTRIBUTE81,
            new_PRICING_ATTRIBUTE82,
            new_PRICING_ATTRIBUTE83,
            new_PRICING_ATTRIBUTE84,
            new_PRICING_ATTRIBUTE85,
            new_PRICING_ATTRIBUTE86,
            new_PRICING_ATTRIBUTE87,
            new_PRICING_ATTRIBUTE88,
            new_PRICING_ATTRIBUTE89,
            new_PRICING_ATTRIBUTE90,
            new_PRICING_ATTRIBUTE91,
            new_PRICING_ATTRIBUTE92,
            new_PRICING_ATTRIBUTE93,
            new_PRICING_ATTRIBUTE94,
            new_PRICING_ATTRIBUTE95,
            new_PRICING_ATTRIBUTE96,
            new_PRICING_ATTRIBUTE97,
            new_PRICING_ATTRIBUTE98,
            new_PRICING_ATTRIBUTE99,
            new_PRICING_ATTRIBUTE100,
            new_active_start_date,
            new_active_end_date,
            new_context,
            new_attribute1 ,
            new_attribute2,
            new_attribute3,
            new_attribute4,
            new_attribute5,
            new_attribute6,
            new_attribute7,
            new_attribute8,
            new_attribute9,
            new_attribute10,
            new_attribute11,
            new_attribute12,
            new_attribute13,
            new_attribute14,
            new_attribute15
  FROM    csi_i_pricing_attribs_h
  WHERE   pricing_attribute_id = p_pri_hist_id
  ORDER BY creation_date;

BEGIN

  FOR C1 IN Int_no_dump(p_pri_hist_id)
  LOOP
     IF Int_no_dump%ROWCOUNT = 1 THEN
         x_first_no_dump                 :=   C1.creation_date;
         x_pri_rec.PRICING_CONTEXT       :=   C1.new_PRICING_CONTEXT;
         x_pri_rec.PRICING_ATTRIBUTE1    :=   C1.new_PRICING_ATTRIBUTE1;
         x_pri_rec.PRICING_ATTRIBUTE2    :=   C1.new_PRICING_ATTRIBUTE2;
         x_pri_rec.PRICING_ATTRIBUTE3    :=   C1.new_PRICING_ATTRIBUTE3;
         x_pri_rec.PRICING_ATTRIBUTE4    :=   C1.new_PRICING_ATTRIBUTE4;
         x_pri_rec.PRICING_ATTRIBUTE5    :=   C1.new_PRICING_ATTRIBUTE5;
         x_pri_rec.PRICING_ATTRIBUTE6    :=   C1.new_PRICING_ATTRIBUTE6;
         x_pri_rec.PRICING_ATTRIBUTE7    :=   C1.new_PRICING_ATTRIBUTE7;
         x_pri_rec.PRICING_ATTRIBUTE8    :=   C1.new_PRICING_ATTRIBUTE8;
         x_pri_rec.PRICING_ATTRIBUTE9    :=   C1.new_PRICING_ATTRIBUTE9;
         x_pri_rec.PRICING_ATTRIBUTE10   :=   C1.new_PRICING_ATTRIBUTE10;
         x_pri_rec.PRICING_ATTRIBUTE11   :=   C1.new_PRICING_ATTRIBUTE11;
         x_pri_rec.PRICING_ATTRIBUTE12   :=   C1.new_PRICING_ATTRIBUTE12;
         x_pri_rec.PRICING_ATTRIBUTE13   :=   C1.new_PRICING_ATTRIBUTE13;
         x_pri_rec.PRICING_ATTRIBUTE14   :=   C1.new_PRICING_ATTRIBUTE14;
         x_pri_rec.PRICING_ATTRIBUTE15   :=   C1.new_PRICING_ATTRIBUTE15;
         x_pri_rec.PRICING_ATTRIBUTE16   :=   C1.new_PRICING_ATTRIBUTE16;
         x_pri_rec.PRICING_ATTRIBUTE17   :=   C1.new_PRICING_ATTRIBUTE17;
         x_pri_rec.PRICING_ATTRIBUTE18   :=   C1.new_PRICING_ATTRIBUTE18;
         x_pri_rec.PRICING_ATTRIBUTE19   :=   C1.new_PRICING_ATTRIBUTE19;
         x_pri_rec.PRICING_ATTRIBUTE20   :=   C1.new_PRICING_ATTRIBUTE20;
         x_pri_rec.PRICING_ATTRIBUTE21   :=   C1.new_PRICING_ATTRIBUTE21;
         x_pri_rec.PRICING_ATTRIBUTE22   :=   C1.new_PRICING_ATTRIBUTE22;
         x_pri_rec.PRICING_ATTRIBUTE23   :=   C1.new_PRICING_ATTRIBUTE23;
         x_pri_rec.PRICING_ATTRIBUTE24   :=   C1.new_PRICING_ATTRIBUTE24;
         x_pri_rec.PRICING_ATTRIBUTE25   :=   C1.new_PRICING_ATTRIBUTE25;
         x_pri_rec.PRICING_ATTRIBUTE26   :=   C1.new_PRICING_ATTRIBUTE26;
         x_pri_rec.PRICING_ATTRIBUTE27   :=   C1.new_PRICING_ATTRIBUTE27;
         x_pri_rec.PRICING_ATTRIBUTE28   :=   C1.new_PRICING_ATTRIBUTE28;
         x_pri_rec.PRICING_ATTRIBUTE29   :=   C1.new_PRICING_ATTRIBUTE29;
         x_pri_rec.PRICING_ATTRIBUTE30   :=   C1.new_PRICING_ATTRIBUTE30;
         x_pri_rec.PRICING_ATTRIBUTE31   :=   C1.new_PRICING_ATTRIBUTE31;
         x_pri_rec.PRICING_ATTRIBUTE32   :=   C1.new_PRICING_ATTRIBUTE32;
         x_pri_rec.PRICING_ATTRIBUTE33   :=   C1.new_PRICING_ATTRIBUTE33;
         x_pri_rec.PRICING_ATTRIBUTE34   :=   C1.new_PRICING_ATTRIBUTE34;
         x_pri_rec.PRICING_ATTRIBUTE35   :=   C1.new_PRICING_ATTRIBUTE35;
         x_pri_rec.PRICING_ATTRIBUTE36   :=   C1.new_PRICING_ATTRIBUTE36;
         x_pri_rec.PRICING_ATTRIBUTE37   :=   C1.new_PRICING_ATTRIBUTE37;
         x_pri_rec.PRICING_ATTRIBUTE38   :=   C1.new_PRICING_ATTRIBUTE38;
         x_pri_rec.PRICING_ATTRIBUTE39   :=   C1.new_PRICING_ATTRIBUTE39;
         x_pri_rec.PRICING_ATTRIBUTE40   :=   C1.new_PRICING_ATTRIBUTE40;
         x_pri_rec.PRICING_ATTRIBUTE41   :=   C1.new_PRICING_ATTRIBUTE41;
         x_pri_rec.PRICING_ATTRIBUTE42   :=   C1.new_PRICING_ATTRIBUTE42;
         x_pri_rec.PRICING_ATTRIBUTE43   :=   C1.new_PRICING_ATTRIBUTE43;
         x_pri_rec.PRICING_ATTRIBUTE44   :=   C1.new_PRICING_ATTRIBUTE44;
         x_pri_rec.PRICING_ATTRIBUTE45   :=   C1.new_PRICING_ATTRIBUTE45;
         x_pri_rec.PRICING_ATTRIBUTE46   :=   C1.new_PRICING_ATTRIBUTE46;
         x_pri_rec.PRICING_ATTRIBUTE47   :=   C1.new_PRICING_ATTRIBUTE47;
         x_pri_rec.PRICING_ATTRIBUTE48   :=   C1.new_PRICING_ATTRIBUTE48;
         x_pri_rec.PRICING_ATTRIBUTE49   :=   C1.new_PRICING_ATTRIBUTE49;
         x_pri_rec.PRICING_ATTRIBUTE50   :=   C1.new_PRICING_ATTRIBUTE50;
         x_pri_rec.PRICING_ATTRIBUTE51   :=   C1.new_PRICING_ATTRIBUTE51;
         x_pri_rec.PRICING_ATTRIBUTE52   :=   C1.new_PRICING_ATTRIBUTE52;
         x_pri_rec.PRICING_ATTRIBUTE53   :=   C1.new_PRICING_ATTRIBUTE53;
         x_pri_rec.PRICING_ATTRIBUTE54   :=   C1.new_PRICING_ATTRIBUTE54;
         x_pri_rec.PRICING_ATTRIBUTE55   :=   C1.new_PRICING_ATTRIBUTE55;
         x_pri_rec.PRICING_ATTRIBUTE56   :=   C1.new_PRICING_ATTRIBUTE56;
         x_pri_rec.PRICING_ATTRIBUTE57   :=   C1.new_PRICING_ATTRIBUTE57;
         x_pri_rec.PRICING_ATTRIBUTE58   :=   C1.new_PRICING_ATTRIBUTE58;
         x_pri_rec.PRICING_ATTRIBUTE59   :=   C1.new_PRICING_ATTRIBUTE59;
         x_pri_rec.PRICING_ATTRIBUTE60   :=   C1.new_PRICING_ATTRIBUTE60;
         x_pri_rec.PRICING_ATTRIBUTE61   :=   C1.new_PRICING_ATTRIBUTE61;
         x_pri_rec.PRICING_ATTRIBUTE62   :=   C1.new_PRICING_ATTRIBUTE62;
         x_pri_rec.PRICING_ATTRIBUTE63   :=   C1.new_PRICING_ATTRIBUTE63;
         x_pri_rec.PRICING_ATTRIBUTE64   :=   C1.new_PRICING_ATTRIBUTE64;
         x_pri_rec.PRICING_ATTRIBUTE65   :=   C1.new_PRICING_ATTRIBUTE65;
         x_pri_rec.PRICING_ATTRIBUTE66   :=   C1.new_PRICING_ATTRIBUTE66;
         x_pri_rec.PRICING_ATTRIBUTE67   :=   C1.new_PRICING_ATTRIBUTE67;
         x_pri_rec.PRICING_ATTRIBUTE68   :=   C1.new_PRICING_ATTRIBUTE68;
         x_pri_rec.PRICING_ATTRIBUTE69   :=   C1.new_PRICING_ATTRIBUTE69;
         x_pri_rec.PRICING_ATTRIBUTE70   :=   C1.new_PRICING_ATTRIBUTE70;
         x_pri_rec.PRICING_ATTRIBUTE71   :=   C1.new_PRICING_ATTRIBUTE71;
         x_pri_rec.PRICING_ATTRIBUTE72   :=   C1.new_PRICING_ATTRIBUTE72;
         x_pri_rec.PRICING_ATTRIBUTE73   :=   C1.new_PRICING_ATTRIBUTE73;
         x_pri_rec.PRICING_ATTRIBUTE74   :=   C1.new_PRICING_ATTRIBUTE74;
         x_pri_rec.PRICING_ATTRIBUTE75   :=   C1.new_PRICING_ATTRIBUTE75;
         x_pri_rec.PRICING_ATTRIBUTE76   :=   C1.new_PRICING_ATTRIBUTE76;
         x_pri_rec.PRICING_ATTRIBUTE77   :=   C1.new_PRICING_ATTRIBUTE77;
         x_pri_rec.PRICING_ATTRIBUTE78   :=   C1.new_PRICING_ATTRIBUTE78;
         x_pri_rec.PRICING_ATTRIBUTE79   :=   C1.new_PRICING_ATTRIBUTE79;
         x_pri_rec.PRICING_ATTRIBUTE80   :=   C1.new_PRICING_ATTRIBUTE80;
         x_pri_rec.PRICING_ATTRIBUTE81   :=   C1.new_PRICING_ATTRIBUTE81;
         x_pri_rec.PRICING_ATTRIBUTE82   :=   C1.new_PRICING_ATTRIBUTE82;
         x_pri_rec.PRICING_ATTRIBUTE83   :=   C1.new_PRICING_ATTRIBUTE83;
         x_pri_rec.PRICING_ATTRIBUTE84   :=   C1.new_PRICING_ATTRIBUTE84;
         x_pri_rec.PRICING_ATTRIBUTE85   :=   C1.new_PRICING_ATTRIBUTE85;
         x_pri_rec.PRICING_ATTRIBUTE86   :=   C1.new_PRICING_ATTRIBUTE86;
         x_pri_rec.PRICING_ATTRIBUTE87   :=   C1.new_PRICING_ATTRIBUTE87;
         x_pri_rec.PRICING_ATTRIBUTE88   :=   C1.new_PRICING_ATTRIBUTE88;
         x_pri_rec.PRICING_ATTRIBUTE89   :=   C1.new_PRICING_ATTRIBUTE89;
         x_pri_rec.PRICING_ATTRIBUTE90   :=   C1.new_PRICING_ATTRIBUTE90;
         x_pri_rec.PRICING_ATTRIBUTE91   :=   C1.new_PRICING_ATTRIBUTE91;
         x_pri_rec.PRICING_ATTRIBUTE92   :=   C1.new_PRICING_ATTRIBUTE92;
         x_pri_rec.PRICING_ATTRIBUTE93   :=   C1.new_PRICING_ATTRIBUTE93;
         x_pri_rec.PRICING_ATTRIBUTE94   :=   C1.new_PRICING_ATTRIBUTE94;
         x_pri_rec.PRICING_ATTRIBUTE95   :=   C1.new_PRICING_ATTRIBUTE95;
         x_pri_rec.PRICING_ATTRIBUTE96   :=   C1.new_PRICING_ATTRIBUTE96;
         x_pri_rec.PRICING_ATTRIBUTE97   :=   C1.new_PRICING_ATTRIBUTE97;
         x_pri_rec.PRICING_ATTRIBUTE98   :=   C1.new_PRICING_ATTRIBUTE98;
         x_pri_rec.PRICING_ATTRIBUTE99   :=   C1.new_PRICING_ATTRIBUTE99;
         x_pri_rec.PRICING_ATTRIBUTE100  :=   C1.new_PRICING_ATTRIBUTE100;
         x_pri_rec.active_start_date     :=   C1.new_active_start_date;
         x_pri_rec.active_end_date       :=   C1.new_active_end_date;
         x_pri_rec.context               :=   C1.new_context;
         x_pri_rec.attribute1            :=   C1.new_attribute1;
         x_pri_rec.attribute2            :=   C1.new_attribute2;
         x_pri_rec.attribute3            :=   C1.new_attribute3;
         x_pri_rec.attribute4            :=   C1.new_attribute4;
         x_pri_rec.attribute5            :=   C1.new_attribute5;
         x_pri_rec.attribute6            :=   C1.new_attribute6;
         x_pri_rec.attribute7            :=   C1.new_attribute7;
         x_pri_rec.attribute8            :=   C1.new_attribute8;
         x_pri_rec.attribute9            :=   C1.new_attribute9;
         x_pri_rec.attribute10           :=   C1.new_attribute10;
         x_pri_rec.attribute11           :=   C1.new_attribute11;
         x_pri_rec.attribute12           :=   C1.new_attribute12;
         x_pri_rec.attribute13           :=   C1.new_attribute13;
         x_pri_rec.attribute14           :=   C1.new_attribute14;
         x_pri_rec.attribute15           :=   C1.new_attribute15;
     ELSE
        EXIT;
     END IF;
  END LOOP;
END Initialize_pri_rec_no_dump;


/*----------------------------------------------------------*/
/* Procedure name:  Initialize_pri_rec                      */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Initialize_pri_rec
( x_pri_rec               IN OUT NOCOPY  csi_datastructures_pub.pricing_attribs_rec,
  p_pri_h_id              IN NUMBER,
  x_nearest_full_dump     IN OUT NOCOPY DATE
) IS

  CURSOR Int_nearest_full_dump(p_pri_att_hist_id IN NUMBER ) IS
  SELECT    creation_date,
            new_PRICING_CONTEXT,
            new_PRICING_ATTRIBUTE1,
            new_PRICING_ATTRIBUTE2,
            new_PRICING_ATTRIBUTE3,
            new_PRICING_ATTRIBUTE4,
            new_PRICING_ATTRIBUTE5,
            new_PRICING_ATTRIBUTE6,
            new_PRICING_ATTRIBUTE7,
            new_PRICING_ATTRIBUTE8,
            new_PRICING_ATTRIBUTE9,
            new_PRICING_ATTRIBUTE10,
            new_PRICING_ATTRIBUTE11,
            new_PRICING_ATTRIBUTE12,
            new_PRICING_ATTRIBUTE13,
            new_PRICING_ATTRIBUTE14,
            new_PRICING_ATTRIBUTE15,
            new_PRICING_ATTRIBUTE16,
            new_PRICING_ATTRIBUTE17,
            new_PRICING_ATTRIBUTE18,
            new_PRICING_ATTRIBUTE19,
            new_PRICING_ATTRIBUTE20,
            new_PRICING_ATTRIBUTE21,
            new_PRICING_ATTRIBUTE22,
            new_PRICING_ATTRIBUTE23,
            new_PRICING_ATTRIBUTE24,
            new_PRICING_ATTRIBUTE25,
            new_PRICING_ATTRIBUTE26,
            new_PRICING_ATTRIBUTE27,
            new_PRICING_ATTRIBUTE28,
            new_PRICING_ATTRIBUTE29,
            new_PRICING_ATTRIBUTE30,
            new_PRICING_ATTRIBUTE31,
            new_PRICING_ATTRIBUTE32,
            new_PRICING_ATTRIBUTE33,
            new_PRICING_ATTRIBUTE34,
            new_PRICING_ATTRIBUTE35,
            new_PRICING_ATTRIBUTE36,
            new_PRICING_ATTRIBUTE37,
            new_PRICING_ATTRIBUTE38,
            new_PRICING_ATTRIBUTE39,
            new_PRICING_ATTRIBUTE40,
            new_PRICING_ATTRIBUTE41,
            new_PRICING_ATTRIBUTE42,
            new_PRICING_ATTRIBUTE43,
            new_PRICING_ATTRIBUTE44,
            new_PRICING_ATTRIBUTE45,
            new_PRICING_ATTRIBUTE46,
            new_PRICING_ATTRIBUTE47,
            new_PRICING_ATTRIBUTE48,
            new_PRICING_ATTRIBUTE49,
            new_PRICING_ATTRIBUTE50,
            new_PRICING_ATTRIBUTE51,
            new_PRICING_ATTRIBUTE52,
            new_PRICING_ATTRIBUTE53,
            new_PRICING_ATTRIBUTE54,
            new_PRICING_ATTRIBUTE55,
            new_PRICING_ATTRIBUTE56,
            new_PRICING_ATTRIBUTE57,
            new_PRICING_ATTRIBUTE58,
            new_PRICING_ATTRIBUTE59,
            new_PRICING_ATTRIBUTE60,
            new_PRICING_ATTRIBUTE61,
            new_PRICING_ATTRIBUTE62,
            new_PRICING_ATTRIBUTE63,
            new_PRICING_ATTRIBUTE64,
            new_PRICING_ATTRIBUTE65,
            new_PRICING_ATTRIBUTE66,
            new_PRICING_ATTRIBUTE67,
            new_PRICING_ATTRIBUTE68,
            new_PRICING_ATTRIBUTE69,
            new_PRICING_ATTRIBUTE70,
            new_PRICING_ATTRIBUTE71,
            new_PRICING_ATTRIBUTE72,
            new_PRICING_ATTRIBUTE73,
            new_PRICING_ATTRIBUTE74,
            new_PRICING_ATTRIBUTE75,
            new_PRICING_ATTRIBUTE76,
            new_PRICING_ATTRIBUTE77,
            new_PRICING_ATTRIBUTE78,
            new_PRICING_ATTRIBUTE79,
            new_PRICING_ATTRIBUTE80,
            new_PRICING_ATTRIBUTE81,
            new_PRICING_ATTRIBUTE82,
            new_PRICING_ATTRIBUTE83,
            new_PRICING_ATTRIBUTE84,
            new_PRICING_ATTRIBUTE85,
            new_PRICING_ATTRIBUTE86,
            new_PRICING_ATTRIBUTE87,
            new_PRICING_ATTRIBUTE88,
            new_PRICING_ATTRIBUTE89,
            new_PRICING_ATTRIBUTE90,
            new_PRICING_ATTRIBUTE91,
            new_PRICING_ATTRIBUTE92,
            new_PRICING_ATTRIBUTE93,
            new_PRICING_ATTRIBUTE94,
            new_PRICING_ATTRIBUTE95,
            new_PRICING_ATTRIBUTE96,
            new_PRICING_ATTRIBUTE97,
            new_PRICING_ATTRIBUTE98,
            new_PRICING_ATTRIBUTE99,
            new_PRICING_ATTRIBUTE100,
            new_active_start_date,
            new_active_end_date,
            new_context,
            new_attribute1 ,
            new_attribute2,
            new_attribute3,
            new_attribute4,
            new_attribute5,
            new_attribute6,
            new_attribute7,
            new_attribute8,
            new_attribute9,
            new_attribute10,
            new_attribute11,
            new_attribute12,
            new_attribute13,
            new_attribute14,
            new_attribute15
  FROM    csi_i_pricing_attribs_h
  WHERE   price_attrib_history_id = p_pri_att_hist_id
  AND     full_dump_flag = 'Y';

BEGIN

  FOR C1 IN Int_nearest_full_dump(p_pri_h_id)
  LOOP
     x_nearest_full_dump             :=   C1.creation_date;
     x_pri_rec.PRICING_CONTEXT       :=   C1.new_PRICING_CONTEXT;
     x_pri_rec.PRICING_ATTRIBUTE1    :=   C1.new_PRICING_ATTRIBUTE1;
     x_pri_rec.PRICING_ATTRIBUTE2    :=   C1.new_PRICING_ATTRIBUTE2;
     x_pri_rec.PRICING_ATTRIBUTE3    :=   C1.new_PRICING_ATTRIBUTE3;
     x_pri_rec.PRICING_ATTRIBUTE4    :=   C1.new_PRICING_ATTRIBUTE4;
     x_pri_rec.PRICING_ATTRIBUTE5    :=   C1.new_PRICING_ATTRIBUTE5;
     x_pri_rec.PRICING_ATTRIBUTE6    :=   C1.new_PRICING_ATTRIBUTE6;
     x_pri_rec.PRICING_ATTRIBUTE7    :=   C1.new_PRICING_ATTRIBUTE7;
     x_pri_rec.PRICING_ATTRIBUTE8    :=   C1.new_PRICING_ATTRIBUTE8;
     x_pri_rec.PRICING_ATTRIBUTE9    :=   C1.new_PRICING_ATTRIBUTE9;
     x_pri_rec.PRICING_ATTRIBUTE10   :=   C1.new_PRICING_ATTRIBUTE10;
     x_pri_rec.PRICING_ATTRIBUTE11   :=   C1.new_PRICING_ATTRIBUTE11;
     x_pri_rec.PRICING_ATTRIBUTE12   :=   C1.new_PRICING_ATTRIBUTE12;
     x_pri_rec.PRICING_ATTRIBUTE13   :=   C1.new_PRICING_ATTRIBUTE13;
     x_pri_rec.PRICING_ATTRIBUTE14   :=   C1.new_PRICING_ATTRIBUTE14;
     x_pri_rec.PRICING_ATTRIBUTE15   :=   C1.new_PRICING_ATTRIBUTE15;
     x_pri_rec.PRICING_ATTRIBUTE16   :=   C1.new_PRICING_ATTRIBUTE16;
     x_pri_rec.PRICING_ATTRIBUTE17   :=   C1.new_PRICING_ATTRIBUTE17;
     x_pri_rec.PRICING_ATTRIBUTE18   :=   C1.new_PRICING_ATTRIBUTE18;
     x_pri_rec.PRICING_ATTRIBUTE19   :=   C1.new_PRICING_ATTRIBUTE19;
     x_pri_rec.PRICING_ATTRIBUTE20   :=   C1.new_PRICING_ATTRIBUTE20;
     x_pri_rec.PRICING_ATTRIBUTE21   :=   C1.new_PRICING_ATTRIBUTE21;
     x_pri_rec.PRICING_ATTRIBUTE22   :=   C1.new_PRICING_ATTRIBUTE22;
     x_pri_rec.PRICING_ATTRIBUTE23   :=   C1.new_PRICING_ATTRIBUTE23;
     x_pri_rec.PRICING_ATTRIBUTE24   :=   C1.new_PRICING_ATTRIBUTE24;
     x_pri_rec.PRICING_ATTRIBUTE25   :=   C1.new_PRICING_ATTRIBUTE25;
     x_pri_rec.PRICING_ATTRIBUTE26   :=   C1.new_PRICING_ATTRIBUTE26;
     x_pri_rec.PRICING_ATTRIBUTE27   :=   C1.new_PRICING_ATTRIBUTE27;
     x_pri_rec.PRICING_ATTRIBUTE28   :=   C1.new_PRICING_ATTRIBUTE28;
     x_pri_rec.PRICING_ATTRIBUTE29   :=   C1.new_PRICING_ATTRIBUTE29;
     x_pri_rec.PRICING_ATTRIBUTE30   :=   C1.new_PRICING_ATTRIBUTE30;
     x_pri_rec.PRICING_ATTRIBUTE31   :=   C1.new_PRICING_ATTRIBUTE31;
     x_pri_rec.PRICING_ATTRIBUTE32   :=   C1.new_PRICING_ATTRIBUTE32;
     x_pri_rec.PRICING_ATTRIBUTE33   :=   C1.new_PRICING_ATTRIBUTE33;
     x_pri_rec.PRICING_ATTRIBUTE34   :=   C1.new_PRICING_ATTRIBUTE34;
     x_pri_rec.PRICING_ATTRIBUTE35   :=   C1.new_PRICING_ATTRIBUTE35;
     x_pri_rec.PRICING_ATTRIBUTE36   :=   C1.new_PRICING_ATTRIBUTE36;
     x_pri_rec.PRICING_ATTRIBUTE37   :=   C1.new_PRICING_ATTRIBUTE37;
     x_pri_rec.PRICING_ATTRIBUTE38   :=   C1.new_PRICING_ATTRIBUTE38;
     x_pri_rec.PRICING_ATTRIBUTE39   :=   C1.new_PRICING_ATTRIBUTE39;
     x_pri_rec.PRICING_ATTRIBUTE40   :=   C1.new_PRICING_ATTRIBUTE40;
     x_pri_rec.PRICING_ATTRIBUTE41   :=   C1.new_PRICING_ATTRIBUTE41;
     x_pri_rec.PRICING_ATTRIBUTE42   :=   C1.new_PRICING_ATTRIBUTE42;
     x_pri_rec.PRICING_ATTRIBUTE43   :=   C1.new_PRICING_ATTRIBUTE43;
     x_pri_rec.PRICING_ATTRIBUTE44   :=   C1.new_PRICING_ATTRIBUTE44;
     x_pri_rec.PRICING_ATTRIBUTE45   :=   C1.new_PRICING_ATTRIBUTE45;
     x_pri_rec.PRICING_ATTRIBUTE46   :=   C1.new_PRICING_ATTRIBUTE46;
     x_pri_rec.PRICING_ATTRIBUTE47   :=   C1.new_PRICING_ATTRIBUTE47;
     x_pri_rec.PRICING_ATTRIBUTE48   :=   C1.new_PRICING_ATTRIBUTE48;
     x_pri_rec.PRICING_ATTRIBUTE49   :=   C1.new_PRICING_ATTRIBUTE49;
     x_pri_rec.PRICING_ATTRIBUTE50   :=   C1.new_PRICING_ATTRIBUTE50;
     x_pri_rec.PRICING_ATTRIBUTE51   :=   C1.new_PRICING_ATTRIBUTE51;
     x_pri_rec.PRICING_ATTRIBUTE52   :=   C1.new_PRICING_ATTRIBUTE52;
     x_pri_rec.PRICING_ATTRIBUTE53   :=   C1.new_PRICING_ATTRIBUTE53;
     x_pri_rec.PRICING_ATTRIBUTE54   :=   C1.new_PRICING_ATTRIBUTE54;
     x_pri_rec.PRICING_ATTRIBUTE55   :=   C1.new_PRICING_ATTRIBUTE55;
     x_pri_rec.PRICING_ATTRIBUTE56   :=   C1.new_PRICING_ATTRIBUTE56;
     x_pri_rec.PRICING_ATTRIBUTE57   :=   C1.new_PRICING_ATTRIBUTE57;
     x_pri_rec.PRICING_ATTRIBUTE58   :=   C1.new_PRICING_ATTRIBUTE58;
     x_pri_rec.PRICING_ATTRIBUTE59   :=   C1.new_PRICING_ATTRIBUTE59;
     x_pri_rec.PRICING_ATTRIBUTE60   :=   C1.new_PRICING_ATTRIBUTE60;
     x_pri_rec.PRICING_ATTRIBUTE61   :=   C1.new_PRICING_ATTRIBUTE61;
     x_pri_rec.PRICING_ATTRIBUTE62   :=   C1.new_PRICING_ATTRIBUTE62;
     x_pri_rec.PRICING_ATTRIBUTE63   :=   C1.new_PRICING_ATTRIBUTE63;
     x_pri_rec.PRICING_ATTRIBUTE64   :=   C1.new_PRICING_ATTRIBUTE64;
     x_pri_rec.PRICING_ATTRIBUTE65   :=   C1.new_PRICING_ATTRIBUTE65;
     x_pri_rec.PRICING_ATTRIBUTE66   :=   C1.new_PRICING_ATTRIBUTE66;
     x_pri_rec.PRICING_ATTRIBUTE67   :=   C1.new_PRICING_ATTRIBUTE67;
     x_pri_rec.PRICING_ATTRIBUTE68   :=   C1.new_PRICING_ATTRIBUTE68;
     x_pri_rec.PRICING_ATTRIBUTE69   :=   C1.new_PRICING_ATTRIBUTE69;
     x_pri_rec.PRICING_ATTRIBUTE70   :=   C1.new_PRICING_ATTRIBUTE70;
     x_pri_rec.PRICING_ATTRIBUTE71   :=   C1.new_PRICING_ATTRIBUTE71;
     x_pri_rec.PRICING_ATTRIBUTE72   :=   C1.new_PRICING_ATTRIBUTE72;
     x_pri_rec.PRICING_ATTRIBUTE73   :=   C1.new_PRICING_ATTRIBUTE73;
     x_pri_rec.PRICING_ATTRIBUTE74   :=   C1.new_PRICING_ATTRIBUTE74;
     x_pri_rec.PRICING_ATTRIBUTE75   :=   C1.new_PRICING_ATTRIBUTE75;
     x_pri_rec.PRICING_ATTRIBUTE76   :=   C1.new_PRICING_ATTRIBUTE76;
     x_pri_rec.PRICING_ATTRIBUTE77   :=   C1.new_PRICING_ATTRIBUTE77;
     x_pri_rec.PRICING_ATTRIBUTE78   :=   C1.new_PRICING_ATTRIBUTE78;
     x_pri_rec.PRICING_ATTRIBUTE79   :=   C1.new_PRICING_ATTRIBUTE79;
     x_pri_rec.PRICING_ATTRIBUTE80   :=   C1.new_PRICING_ATTRIBUTE80;
     x_pri_rec.PRICING_ATTRIBUTE81   :=   C1.new_PRICING_ATTRIBUTE81;
     x_pri_rec.PRICING_ATTRIBUTE82   :=   C1.new_PRICING_ATTRIBUTE82;
     x_pri_rec.PRICING_ATTRIBUTE83   :=   C1.new_PRICING_ATTRIBUTE83;
     x_pri_rec.PRICING_ATTRIBUTE84   :=   C1.new_PRICING_ATTRIBUTE84;
     x_pri_rec.PRICING_ATTRIBUTE85   :=   C1.new_PRICING_ATTRIBUTE85;
     x_pri_rec.PRICING_ATTRIBUTE86   :=   C1.new_PRICING_ATTRIBUTE86;
     x_pri_rec.PRICING_ATTRIBUTE87   :=   C1.new_PRICING_ATTRIBUTE87;
     x_pri_rec.PRICING_ATTRIBUTE88   :=   C1.new_PRICING_ATTRIBUTE88;
     x_pri_rec.PRICING_ATTRIBUTE89   :=   C1.new_PRICING_ATTRIBUTE89;
     x_pri_rec.PRICING_ATTRIBUTE90   :=   C1.new_PRICING_ATTRIBUTE90;
     x_pri_rec.PRICING_ATTRIBUTE91   :=   C1.new_PRICING_ATTRIBUTE91;
     x_pri_rec.PRICING_ATTRIBUTE92   :=   C1.new_PRICING_ATTRIBUTE92;
     x_pri_rec.PRICING_ATTRIBUTE93   :=   C1.new_PRICING_ATTRIBUTE93;
     x_pri_rec.PRICING_ATTRIBUTE94   :=   C1.new_PRICING_ATTRIBUTE94;
     x_pri_rec.PRICING_ATTRIBUTE95   :=   C1.new_PRICING_ATTRIBUTE95;
     x_pri_rec.PRICING_ATTRIBUTE96   :=   C1.new_PRICING_ATTRIBUTE96;
     x_pri_rec.PRICING_ATTRIBUTE97   :=   C1.new_PRICING_ATTRIBUTE97;
     x_pri_rec.PRICING_ATTRIBUTE98   :=   C1.new_PRICING_ATTRIBUTE98;
     x_pri_rec.PRICING_ATTRIBUTE99   :=   C1.new_PRICING_ATTRIBUTE99;
     x_pri_rec.PRICING_ATTRIBUTE100  :=   C1.new_PRICING_ATTRIBUTE100;
     x_pri_rec.active_start_date     :=   C1.new_active_start_date;
     x_pri_rec.active_end_date       :=   C1.new_active_end_date;
     x_pri_rec.context               :=   C1.new_context;
     x_pri_rec.attribute1            :=   C1.new_attribute1;
     x_pri_rec.attribute2            :=   C1.new_attribute2;
     x_pri_rec.attribute3            :=   C1.new_attribute3;
     x_pri_rec.attribute4            :=   C1.new_attribute4;
     x_pri_rec.attribute5            :=   C1.new_attribute5;
     x_pri_rec.attribute6            :=   C1.new_attribute6;
     x_pri_rec.attribute7            :=   C1.new_attribute7;
     x_pri_rec.attribute8            :=   C1.new_attribute8;
     x_pri_rec.attribute9            :=   C1.new_attribute9;
     x_pri_rec.attribute10           :=   C1.new_attribute10;
     x_pri_rec.attribute11           :=   C1.new_attribute11;
     x_pri_rec.attribute12           :=   C1.new_attribute12;
     x_pri_rec.attribute13           :=   C1.new_attribute13;
     x_pri_rec.attribute14           :=   C1.new_attribute14;
     x_pri_rec.attribute15           :=   C1.new_attribute15;
  END LOOP;
END Initialize_pri_rec ;

/*----------------------------------------------------------*/
/* Procedure name:  Construct_pri_from_hist                  */
/* Description : This procudure recontructs the record      */
/*                 from the history                         */
/*----------------------------------------------------------*/

PROCEDURE Construct_pri_from_hist
  ( x_pri_tbl           IN OUT NOCOPY   csi_datastructures_pub.pricing_attribs_tbl,
    p_time_stamp        IN       DATE
   ) IS

 l_nearest_full_dump    DATE := p_time_stamp;
 l_pri_att_hist_id      NUMBER;
 l_pri_tbl              csi_datastructures_pub.pricing_attribs_tbl;
 l_pri_count            NUMBER := 0;
 --
 Process_next           EXCEPTION;


 CURSOR get_nearest_full_dump( p_pri_att_id IN NUMBER ,
                               p_time       IN DATE ) IS
   SELECT MAX(price_attrib_history_id)
   FROM   csi_i_pricing_attribs_h
   WHERE  creation_date <= p_time
   AND    pricing_attribute_id = p_pri_att_id
   AND    full_dump_flag = 'Y' ;


 CURSOR get_pri_hist(p_pri_att_id        IN NUMBER ,
                     p_nearest_full_dump IN DATE,
                     p_time              IN DATE ) IS
  SELECT    --price_attrib_history_id,
            OLD_PRICING_CONTEXT,
            NEW_PRICING_CONTEXT ,
            OLD_PRICING_ATTRIBUTE1,
            NEW_PRICING_ATTRIBUTE1,
            OLD_PRICING_ATTRIBUTE2,
            NEW_PRICING_ATTRIBUTE2,
            OLD_PRICING_ATTRIBUTE3,
            NEW_PRICING_ATTRIBUTE3,
            OLD_PRICING_ATTRIBUTE4,
            NEW_PRICING_ATTRIBUTE4,
            OLD_PRICING_ATTRIBUTE5,
            NEW_PRICING_ATTRIBUTE5,
            OLD_PRICING_ATTRIBUTE6,
            NEW_PRICING_ATTRIBUTE6,
            OLD_PRICING_ATTRIBUTE7,
            NEW_PRICING_ATTRIBUTE7,
            OLD_PRICING_ATTRIBUTE8,
            NEW_PRICING_ATTRIBUTE8,
            OLD_PRICING_ATTRIBUTE9,
            NEW_PRICING_ATTRIBUTE9,
            OLD_PRICING_ATTRIBUTE10,
            NEW_PRICING_ATTRIBUTE10,
            OLD_PRICING_ATTRIBUTE11,
            NEW_PRICING_ATTRIBUTE11,
            OLD_PRICING_ATTRIBUTE12,
            NEW_PRICING_ATTRIBUTE12,
            OLD_PRICING_ATTRIBUTE13,
            NEW_PRICING_ATTRIBUTE13,
            OLD_PRICING_ATTRIBUTE14,
            NEW_PRICING_ATTRIBUTE14,
            OLD_PRICING_ATTRIBUTE15,
            NEW_PRICING_ATTRIBUTE15,
            OLD_PRICING_ATTRIBUTE16,
            NEW_PRICING_ATTRIBUTE16,
            OLD_PRICING_ATTRIBUTE17,
            NEW_PRICING_ATTRIBUTE17,
            OLD_PRICING_ATTRIBUTE18,
            NEW_PRICING_ATTRIBUTE18,
            OLD_PRICING_ATTRIBUTE19,
            NEW_PRICING_ATTRIBUTE19,
            OLD_PRICING_ATTRIBUTE20,
            NEW_PRICING_ATTRIBUTE20,
            OLD_PRICING_ATTRIBUTE21,
            NEW_PRICING_ATTRIBUTE21,
            OLD_PRICING_ATTRIBUTE22,
            NEW_PRICING_ATTRIBUTE22,
            OLD_PRICING_ATTRIBUTE23,
            NEW_PRICING_ATTRIBUTE23,
            OLD_PRICING_ATTRIBUTE24,
            NEW_PRICING_ATTRIBUTE24,
            NEW_PRICING_ATTRIBUTE25,
            OLD_PRICING_ATTRIBUTE25,
            OLD_PRICING_ATTRIBUTE26,
            NEW_PRICING_ATTRIBUTE26,
            OLD_PRICING_ATTRIBUTE27,
            NEW_PRICING_ATTRIBUTE27,
            OLD_PRICING_ATTRIBUTE28,
            NEW_PRICING_ATTRIBUTE28,
            OLD_PRICING_ATTRIBUTE29,
            NEW_PRICING_ATTRIBUTE29,
            OLD_PRICING_ATTRIBUTE30,
            NEW_PRICING_ATTRIBUTE30,
            OLD_PRICING_ATTRIBUTE31,
            NEW_PRICING_ATTRIBUTE31,
            OLD_PRICING_ATTRIBUTE32,
            NEW_PRICING_ATTRIBUTE32,
            OLD_PRICING_ATTRIBUTE33,
            NEW_PRICING_ATTRIBUTE33,
            OLD_PRICING_ATTRIBUTE34,
            NEW_PRICING_ATTRIBUTE34,
            OLD_PRICING_ATTRIBUTE35,
            NEW_PRICING_ATTRIBUTE35,
            OLD_PRICING_ATTRIBUTE36,
            NEW_PRICING_ATTRIBUTE36,
            OLD_PRICING_ATTRIBUTE37,
            NEW_PRICING_ATTRIBUTE37,
            OLD_PRICING_ATTRIBUTE38,
            NEW_PRICING_ATTRIBUTE38,
            OLD_PRICING_ATTRIBUTE39,
            NEW_PRICING_ATTRIBUTE39,
            OLD_PRICING_ATTRIBUTE40,
            NEW_PRICING_ATTRIBUTE40,
            OLD_PRICING_ATTRIBUTE41,
            NEW_PRICING_ATTRIBUTE41,
            OLD_PRICING_ATTRIBUTE42,
            NEW_PRICING_ATTRIBUTE42,
            OLD_PRICING_ATTRIBUTE43,
            NEW_PRICING_ATTRIBUTE43,
            OLD_PRICING_ATTRIBUTE44,
            NEW_PRICING_ATTRIBUTE44,
            OLD_PRICING_ATTRIBUTE45,
            NEW_PRICING_ATTRIBUTE45,
            OLD_PRICING_ATTRIBUTE46,
            NEW_PRICING_ATTRIBUTE46,
            OLD_PRICING_ATTRIBUTE47,
            NEW_PRICING_ATTRIBUTE47,
            OLD_PRICING_ATTRIBUTE48,
            NEW_PRICING_ATTRIBUTE48,
            OLD_PRICING_ATTRIBUTE49,
            NEW_PRICING_ATTRIBUTE49,
            OLD_PRICING_ATTRIBUTE50,
            NEW_PRICING_ATTRIBUTE50,
            OLD_PRICING_ATTRIBUTE51,
            NEW_PRICING_ATTRIBUTE51,
            OLD_PRICING_ATTRIBUTE52,
            NEW_PRICING_ATTRIBUTE52,
            OLD_PRICING_ATTRIBUTE53,
            NEW_PRICING_ATTRIBUTE53,
            OLD_PRICING_ATTRIBUTE54,
            NEW_PRICING_ATTRIBUTE54,
            OLD_PRICING_ATTRIBUTE55,
            NEW_PRICING_ATTRIBUTE55,
            OLD_PRICING_ATTRIBUTE56,
            NEW_PRICING_ATTRIBUTE56,
            OLD_PRICING_ATTRIBUTE57,
            NEW_PRICING_ATTRIBUTE57,
            OLD_PRICING_ATTRIBUTE58,
            NEW_PRICING_ATTRIBUTE58,
            OLD_PRICING_ATTRIBUTE59,
            NEW_PRICING_ATTRIBUTE59,
            OLD_PRICING_ATTRIBUTE60,
            NEW_PRICING_ATTRIBUTE60,
            OLD_PRICING_ATTRIBUTE61,
            NEW_PRICING_ATTRIBUTE61,
            OLD_PRICING_ATTRIBUTE62,
            NEW_PRICING_ATTRIBUTE62,
            OLD_PRICING_ATTRIBUTE63,
            NEW_PRICING_ATTRIBUTE63,
            OLD_PRICING_ATTRIBUTE64,
            NEW_PRICING_ATTRIBUTE64,
            OLD_PRICING_ATTRIBUTE65,
            NEW_PRICING_ATTRIBUTE65,
            OLD_PRICING_ATTRIBUTE66,
            NEW_PRICING_ATTRIBUTE66,
            OLD_PRICING_ATTRIBUTE67,
            NEW_PRICING_ATTRIBUTE67,
            OLD_PRICING_ATTRIBUTE68,
            NEW_PRICING_ATTRIBUTE68,
            OLD_PRICING_ATTRIBUTE69,
            NEW_PRICING_ATTRIBUTE69,
            OLD_PRICING_ATTRIBUTE70,
            NEW_PRICING_ATTRIBUTE70,
            OLD_PRICING_ATTRIBUTE71,
            NEW_PRICING_ATTRIBUTE71,
            OLD_PRICING_ATTRIBUTE72,
            NEW_PRICING_ATTRIBUTE72,
            OLD_PRICING_ATTRIBUTE73,
            NEW_PRICING_ATTRIBUTE73,
            OLD_PRICING_ATTRIBUTE74,
            NEW_PRICING_ATTRIBUTE74,
            OLD_PRICING_ATTRIBUTE75,
            NEW_PRICING_ATTRIBUTE75,
            OLD_PRICING_ATTRIBUTE76,
            NEW_PRICING_ATTRIBUTE76,
            OLD_PRICING_ATTRIBUTE77,
            NEW_PRICING_ATTRIBUTE77,
            OLD_PRICING_ATTRIBUTE78,
            NEW_PRICING_ATTRIBUTE78,
            OLD_PRICING_ATTRIBUTE79,
            NEW_PRICING_ATTRIBUTE79,
            OLD_PRICING_ATTRIBUTE80,
            NEW_PRICING_ATTRIBUTE80,
            OLD_PRICING_ATTRIBUTE81,
            NEW_PRICING_ATTRIBUTE81,
            OLD_PRICING_ATTRIBUTE82,
            NEW_PRICING_ATTRIBUTE82,
            OLD_PRICING_ATTRIBUTE83,
            NEW_PRICING_ATTRIBUTE83,
            OLD_PRICING_ATTRIBUTE84,
            NEW_PRICING_ATTRIBUTE84,
            OLD_PRICING_ATTRIBUTE85,
            NEW_PRICING_ATTRIBUTE85,
            OLD_PRICING_ATTRIBUTE86,
            NEW_PRICING_ATTRIBUTE86,
            OLD_PRICING_ATTRIBUTE87,
            NEW_PRICING_ATTRIBUTE87,
            OLD_PRICING_ATTRIBUTE88,
            NEW_PRICING_ATTRIBUTE88,
            OLD_PRICING_ATTRIBUTE89,
            NEW_PRICING_ATTRIBUTE89,
            OLD_PRICING_ATTRIBUTE90,
            NEW_PRICING_ATTRIBUTE90,
            OLD_PRICING_ATTRIBUTE91,
            NEW_PRICING_ATTRIBUTE91,
            OLD_PRICING_ATTRIBUTE92,
            NEW_PRICING_ATTRIBUTE92,
            OLD_PRICING_ATTRIBUTE93,
            NEW_PRICING_ATTRIBUTE93,
            OLD_PRICING_ATTRIBUTE94,
            NEW_PRICING_ATTRIBUTE94,
            OLD_PRICING_ATTRIBUTE95,
            NEW_PRICING_ATTRIBUTE95,
            OLD_PRICING_ATTRIBUTE96,
            NEW_PRICING_ATTRIBUTE96,
            OLD_PRICING_ATTRIBUTE97,
            NEW_PRICING_ATTRIBUTE97,
            OLD_PRICING_ATTRIBUTE98,
            NEW_PRICING_ATTRIBUTE98,
            OLD_PRICING_ATTRIBUTE99,
            NEW_PRICING_ATTRIBUTE99,
            OLD_PRICING_ATTRIBUTE100,
            NEW_PRICING_ATTRIBUTE100,
            OLD_ACTIVE_START_DATE,
            NEW_ACTIVE_START_DATE,
            OLD_ACTIVE_END_DATE,
            NEW_ACTIVE_END_DATE,
            OLD_CONTEXT,
            NEW_CONTEXT,
            OLD_ATTRIBUTE1,
            NEW_ATTRIBUTE1,
            OLD_ATTRIBUTE2,
            NEW_ATTRIBUTE2,
            OLD_ATTRIBUTE3,
            NEW_ATTRIBUTE3,
            OLD_ATTRIBUTE4,
            NEW_ATTRIBUTE4,
            OLD_ATTRIBUTE5,
            NEW_ATTRIBUTE5,
            OLD_ATTRIBUTE6,
            NEW_ATTRIBUTE6,
            OLD_ATTRIBUTE7,
            NEW_ATTRIBUTE7,
            OLD_ATTRIBUTE8,
            NEW_ATTRIBUTE8,
            OLD_ATTRIBUTE9,
            NEW_ATTRIBUTE9,
            OLD_ATTRIBUTE10,
            NEW_ATTRIBUTE10,
            OLD_ATTRIBUTE11,
            NEW_ATTRIBUTE11,
            OLD_ATTRIBUTE12,
            NEW_ATTRIBUTE12,
            OLD_ATTRIBUTE13,
            NEW_ATTRIBUTE13,
            OLD_ATTRIBUTE14,
            NEW_ATTRIBUTE14,
            OLD_ATTRIBUTE15,
            NEW_ATTRIBUTE15
  FROM      csi_i_pricing_attribs_h
  WHERE     creation_date <= p_time
  AND       creation_date >= p_nearest_full_dump
  AND       pricing_attribute_id = p_pri_att_id
  ORDER BY  creation_date;

 l_time_stamp   DATE := p_time_stamp;

BEGIN

  l_pri_tbl := x_pri_tbl;

  IF (l_pri_tbl.COUNT > 0) THEN

    FOR i IN l_pri_tbl.FIRST..l_pri_tbl.LAST
    LOOP
     BEGIN

      OPEN get_nearest_full_dump(l_pri_tbl(i).pricing_attribute_id, p_time_stamp);
      FETCH get_nearest_full_dump INTO l_pri_att_hist_id ;
      CLOSE get_nearest_full_dump;

      IF  l_pri_att_hist_id IS NOT NULL THEN
          Initialize_pri_rec( l_pri_tbl(i), l_pri_att_hist_id  ,l_nearest_full_dump);
      ELSE
          Initialize_pri_rec_no_dump(l_pri_tbl(i), l_pri_tbl(i).pricing_attribute_id,l_time_stamp);

          l_nearest_full_dump :=  l_time_stamp;
           -- If the user chooses a date before the creation date of the instance
           -- then raise an error
          IF p_time_stamp < l_time_stamp THEN
              -- Messages Commented for bug 2423342. Records that do not qualify should get deleted.
              -- FND_MESSAGE.SET_NAME('CSI','CSI_H_DATE_BEFORE_CRE_DATE');
              -- FND_MESSAGE.SET_TOKEN('CREATION_DATE',to_char(l_time_stamp, 'DD-MON-YYYY HH24:MI:SS'));
              -- FND_MESSAGE.SET_TOKEN('USER_DATE',to_char(p_time_stamp, 'DD-MON-YYYY HH24:MI:SS'));
              -- FND_MSG_PUB.Add;
              l_pri_tbl.DELETE(i);
              csi_gen_utility_pvt.put_line('Processing Next..');
              RAISE Process_next;
          END IF;
      END IF;

      FOR C2 IN get_pri_hist(x_pri_tbl(i).pricing_attribute_id ,l_nearest_full_dump,p_time_stamp )
      LOOP

           IF (C2.OLD_PRICING_CONTEXT IS NULL AND C2.NEW_PRICING_CONTEXT IS NOT NULL)
           OR (C2.OLD_PRICING_CONTEXT IS NOT NULL AND C2.NEW_PRICING_CONTEXT IS NULL)
           OR (C2.OLD_PRICING_CONTEXT <> C2.NEW_PRICING_CONTEXT) THEN
                l_pri_tbl(i).PRICING_CONTEXT := C2.NEW_PRICING_CONTEXT;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE1 IS NULL AND C2.NEW_PRICING_ATTRIBUTE1 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE1 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE1 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE1 <> C2.NEW_PRICING_ATTRIBUTE1) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE1 := C2.NEW_PRICING_ATTRIBUTE1;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE2 IS NULL AND C2.NEW_PRICING_ATTRIBUTE2 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE2 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE2 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE2 <> C2.NEW_PRICING_ATTRIBUTE2) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE2 := C2.NEW_PRICING_ATTRIBUTE2;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE3 IS NULL AND C2.NEW_PRICING_ATTRIBUTE3 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE3 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE3 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE3 <> C2.NEW_PRICING_ATTRIBUTE3) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE3 := C2.NEW_PRICING_ATTRIBUTE3;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE4 IS NULL AND C2.NEW_PRICING_ATTRIBUTE4 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE4 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE4 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE4 <> C2.NEW_PRICING_ATTRIBUTE4) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE4 := C2.NEW_PRICING_ATTRIBUTE4;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE5 IS NULL AND C2.NEW_PRICING_ATTRIBUTE5 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE5 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE5 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE5 <> C2.NEW_PRICING_ATTRIBUTE5) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE5 := C2.NEW_PRICING_ATTRIBUTE5;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE6 IS NULL AND C2.NEW_PRICING_ATTRIBUTE6 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE6 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE6 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE6 <> C2.NEW_PRICING_ATTRIBUTE6) THEN
               l_pri_tbl(i).PRICING_ATTRIBUTE6 := C2.NEW_PRICING_ATTRIBUTE6;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE7 IS NULL AND C2.NEW_PRICING_ATTRIBUTE7 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE7 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE7 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE7 <> C2.NEW_PRICING_ATTRIBUTE7) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE7 := C2.NEW_PRICING_ATTRIBUTE7;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE8 IS NULL AND C2.NEW_PRICING_ATTRIBUTE8 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE8 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE8 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE8 <> C2.NEW_PRICING_ATTRIBUTE8) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE8 := C2.NEW_PRICING_ATTRIBUTE8;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE9 IS NULL AND C2.NEW_PRICING_ATTRIBUTE9 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE9 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE9 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE9 <> C2.NEW_PRICING_ATTRIBUTE9) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE9 := C2.NEW_PRICING_ATTRIBUTE9;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE10 IS NULL AND C2.NEW_PRICING_ATTRIBUTE10 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE10 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE10 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE10 <> C2.NEW_PRICING_ATTRIBUTE10) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE10 := C2.NEW_PRICING_ATTRIBUTE10;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE11 IS NULL AND C2.NEW_PRICING_ATTRIBUTE11 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE11 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE11 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE11 <> C2.NEW_PRICING_ATTRIBUTE11) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE11 := C2.NEW_PRICING_ATTRIBUTE11;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE12 IS NULL AND C2.NEW_PRICING_ATTRIBUTE12 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE12 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE12 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE12 <> C2.NEW_PRICING_ATTRIBUTE12) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE12 := C2.NEW_PRICING_ATTRIBUTE12;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE13 IS NULL AND C2.NEW_PRICING_ATTRIBUTE13 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE13 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE13 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE13 <> C2.NEW_PRICING_ATTRIBUTE13) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE13 := C2.NEW_PRICING_ATTRIBUTE13;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE14 IS NULL AND C2.NEW_PRICING_ATTRIBUTE14 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE14 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE14 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE14 <> C2.NEW_PRICING_ATTRIBUTE14) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE14 := C2.NEW_PRICING_ATTRIBUTE14;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE15 IS NULL AND C2.NEW_PRICING_ATTRIBUTE15 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE15 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE15 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE15 <> C2.NEW_PRICING_ATTRIBUTE15) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE15 := C2.NEW_PRICING_ATTRIBUTE15;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE16 IS NULL AND C2.NEW_PRICING_ATTRIBUTE16 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE16 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE16 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE16 <> C2.NEW_PRICING_ATTRIBUTE16) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE16 := C2.NEW_PRICING_ATTRIBUTE16;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE17 IS NULL AND C2.NEW_PRICING_ATTRIBUTE17 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE17 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE17 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE17 <> C2.NEW_PRICING_ATTRIBUTE17) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE17 := C2.NEW_PRICING_ATTRIBUTE17;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE18 IS NULL AND C2.NEW_PRICING_ATTRIBUTE18 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE18 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE18 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE18 <> C2.NEW_PRICING_ATTRIBUTE18) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE18 := C2.NEW_PRICING_ATTRIBUTE18;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE19 IS NULL AND C2.NEW_PRICING_ATTRIBUTE19 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE19 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE19 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE19 <> C2.NEW_PRICING_ATTRIBUTE19) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE19 := C2.NEW_PRICING_ATTRIBUTE19;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE20 IS NULL AND C2.NEW_PRICING_ATTRIBUTE20 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE20 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE20 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE20 <> C2.NEW_PRICING_ATTRIBUTE20) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE20 := C2.NEW_PRICING_ATTRIBUTE20;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE21 IS NULL AND C2.NEW_PRICING_ATTRIBUTE21 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE21 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE21 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE21 <> C2.NEW_PRICING_ATTRIBUTE21) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE21 := C2.NEW_PRICING_ATTRIBUTE21;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE22 IS NULL AND C2.NEW_PRICING_ATTRIBUTE22 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE22 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE22 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE22 <> C2.NEW_PRICING_ATTRIBUTE22) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE22 := C2.NEW_PRICING_ATTRIBUTE22;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE23 IS NULL AND C2.NEW_PRICING_ATTRIBUTE23 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE23 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE23 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE23 <> C2.NEW_PRICING_ATTRIBUTE23) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE23 := C2.NEW_PRICING_ATTRIBUTE23;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE24 IS NULL AND C2.NEW_PRICING_ATTRIBUTE24 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE24 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE24 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE24 <> C2.NEW_PRICING_ATTRIBUTE24) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE24 := C2.NEW_PRICING_ATTRIBUTE24;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE25 IS NULL AND C2.NEW_PRICING_ATTRIBUTE25 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE25 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE25 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE25 <> C2.NEW_PRICING_ATTRIBUTE25) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE25 := C2.NEW_PRICING_ATTRIBUTE25;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE26 IS NULL AND C2.NEW_PRICING_ATTRIBUTE26 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE26 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE26 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE26 <> C2.NEW_PRICING_ATTRIBUTE26) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE26 := C2.NEW_PRICING_ATTRIBUTE26;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE27 IS NULL AND C2.NEW_PRICING_ATTRIBUTE27 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE27 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE27 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE27 <> C2.NEW_PRICING_ATTRIBUTE27) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE27 := C2.NEW_PRICING_ATTRIBUTE27;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE28 IS NULL AND C2.NEW_PRICING_ATTRIBUTE28 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE28 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE28 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE28 <> C2.NEW_PRICING_ATTRIBUTE28) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE28 := C2.NEW_PRICING_ATTRIBUTE28;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE29 IS NULL AND C2.NEW_PRICING_ATTRIBUTE29 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE29 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE29 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE29 <> C2.NEW_PRICING_ATTRIBUTE29) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE29 := C2.NEW_PRICING_ATTRIBUTE29;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE30 IS NULL AND C2.NEW_PRICING_ATTRIBUTE30 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE30 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE30 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE30 <> C2.NEW_PRICING_ATTRIBUTE30) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE30 := C2.NEW_PRICING_ATTRIBUTE30;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE31 IS NULL AND C2.NEW_PRICING_ATTRIBUTE31 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE31 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE31 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE31 <> C2.NEW_PRICING_ATTRIBUTE31) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE31 := C2.NEW_PRICING_ATTRIBUTE31;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE32 IS NULL AND C2.NEW_PRICING_ATTRIBUTE32 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE32 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE32 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE32 <> C2.NEW_PRICING_ATTRIBUTE32) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE32 := C2.NEW_PRICING_ATTRIBUTE32;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE33 IS NULL AND C2.NEW_PRICING_ATTRIBUTE33 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE33 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE33 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE33 <> C2.NEW_PRICING_ATTRIBUTE33) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE33 := C2.NEW_PRICING_ATTRIBUTE33;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE34 IS NULL AND C2.NEW_PRICING_ATTRIBUTE34 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE34 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE34 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE34 <> C2.NEW_PRICING_ATTRIBUTE34) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE34 := C2.NEW_PRICING_ATTRIBUTE34;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE35 IS NULL AND C2.NEW_PRICING_ATTRIBUTE35 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE35 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE35 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE35 <> C2.NEW_PRICING_ATTRIBUTE35) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE35 := C2.NEW_PRICING_ATTRIBUTE35;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE36 IS NULL AND C2.NEW_PRICING_ATTRIBUTE36 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE36 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE36 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE36 <> C2.NEW_PRICING_ATTRIBUTE36) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE36 := C2.NEW_PRICING_ATTRIBUTE36;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE37 IS NULL AND C2.NEW_PRICING_ATTRIBUTE37 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE37 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE37 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE37 <> C2.NEW_PRICING_ATTRIBUTE37) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE37 := C2.NEW_PRICING_ATTRIBUTE37;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE38 IS NULL AND C2.NEW_PRICING_ATTRIBUTE38 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE38 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE38 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE38 <> C2.NEW_PRICING_ATTRIBUTE38) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE38 := C2.NEW_PRICING_ATTRIBUTE38;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE39 IS NULL AND C2.NEW_PRICING_ATTRIBUTE39 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE39 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE39 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE39 <> C2.NEW_PRICING_ATTRIBUTE39) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE39 := C2.NEW_PRICING_ATTRIBUTE39;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE40 IS NULL AND C2.NEW_PRICING_ATTRIBUTE40 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE40 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE40 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE40 <> C2.NEW_PRICING_ATTRIBUTE40) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE40 := C2.NEW_PRICING_ATTRIBUTE40;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE41 IS NULL AND C2.NEW_PRICING_ATTRIBUTE41 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE41 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE41 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE41 <> C2.NEW_PRICING_ATTRIBUTE41) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE41 := C2.NEW_PRICING_ATTRIBUTE41;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE42 IS NULL AND C2.NEW_PRICING_ATTRIBUTE42 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE42 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE42 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE42 <> C2.NEW_PRICING_ATTRIBUTE42) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE42 := C2.NEW_PRICING_ATTRIBUTE42;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE43 IS NULL AND C2.NEW_PRICING_ATTRIBUTE43 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE43 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE43 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE43 <> C2.NEW_PRICING_ATTRIBUTE43) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE43 := C2.NEW_PRICING_ATTRIBUTE43;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE44 IS NULL AND C2.NEW_PRICING_ATTRIBUTE44 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE44 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE44 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE44 <> C2.NEW_PRICING_ATTRIBUTE44) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE44 := C2.NEW_PRICING_ATTRIBUTE44;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE45 IS NULL AND C2.NEW_PRICING_ATTRIBUTE45 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE45 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE45 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE45 <> C2.NEW_PRICING_ATTRIBUTE45) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE45 := C2.NEW_PRICING_ATTRIBUTE45;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE46 IS NULL AND C2.NEW_PRICING_ATTRIBUTE46 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE46 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE46 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE46 <> C2.NEW_PRICING_ATTRIBUTE46) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE46 := C2.NEW_PRICING_ATTRIBUTE46;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE47 IS NULL AND C2.NEW_PRICING_ATTRIBUTE47 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE47 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE47 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE47 <> C2.NEW_PRICING_ATTRIBUTE47) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE47 := C2.NEW_PRICING_ATTRIBUTE47;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE48 IS NULL AND C2.NEW_PRICING_ATTRIBUTE48 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE48 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE48 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE48 <> C2.NEW_PRICING_ATTRIBUTE48) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE48 := C2.NEW_PRICING_ATTRIBUTE48;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE49 IS NULL AND C2.NEW_PRICING_ATTRIBUTE49 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE49 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE49 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE49 <> C2.NEW_PRICING_ATTRIBUTE49) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE49 := C2.NEW_PRICING_ATTRIBUTE49;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE50 IS NULL AND C2.NEW_PRICING_ATTRIBUTE50 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE50 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE50 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE50 <> C2.NEW_PRICING_ATTRIBUTE50) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE50 := C2.NEW_PRICING_ATTRIBUTE50;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE51 IS NULL AND C2.NEW_PRICING_ATTRIBUTE51 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE51 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE51 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE51 <> C2.NEW_PRICING_ATTRIBUTE51) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE51 := C2.NEW_PRICING_ATTRIBUTE51;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE52 IS NULL AND C2.NEW_PRICING_ATTRIBUTE52 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE52 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE52 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE52 <> C2.NEW_PRICING_ATTRIBUTE52) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE52 := C2.NEW_PRICING_ATTRIBUTE52;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE53 IS NULL AND C2.NEW_PRICING_ATTRIBUTE53 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE53 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE53 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE53 <> C2.NEW_PRICING_ATTRIBUTE53) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE53 := C2.NEW_PRICING_ATTRIBUTE53;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE54 IS NULL AND C2.NEW_PRICING_ATTRIBUTE54 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE54 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE54 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE54 <> C2.NEW_PRICING_ATTRIBUTE54) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE54 := C2.NEW_PRICING_ATTRIBUTE54;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE55 IS NULL AND C2.NEW_PRICING_ATTRIBUTE55 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE55 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE55 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE55 <> C2.NEW_PRICING_ATTRIBUTE55) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE55 := C2.NEW_PRICING_ATTRIBUTE55;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE56 IS NULL AND C2.NEW_PRICING_ATTRIBUTE56 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE56 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE56 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE56 <> C2.NEW_PRICING_ATTRIBUTE56) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE56 := C2.NEW_PRICING_ATTRIBUTE56;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE57 IS NULL AND C2.NEW_PRICING_ATTRIBUTE57 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE57 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE57 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE57 <> C2.NEW_PRICING_ATTRIBUTE57) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE57 := C2.NEW_PRICING_ATTRIBUTE57;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE58 IS NULL AND C2.NEW_PRICING_ATTRIBUTE58 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE58 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE58 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE58 <> C2.NEW_PRICING_ATTRIBUTE58) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE58 := C2.NEW_PRICING_ATTRIBUTE58;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE59 IS NULL AND C2.NEW_PRICING_ATTRIBUTE59 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE59 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE59 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE59 <> C2.NEW_PRICING_ATTRIBUTE59) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE59 := C2.NEW_PRICING_ATTRIBUTE59;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE60 IS NULL AND C2.NEW_PRICING_ATTRIBUTE60 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE60 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE60 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE60 <> C2.NEW_PRICING_ATTRIBUTE60) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE60 := C2.NEW_PRICING_ATTRIBUTE60;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE61 IS NULL AND C2.NEW_PRICING_ATTRIBUTE61 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE61 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE61 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE61 <> C2.NEW_PRICING_ATTRIBUTE61) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE61 := C2.NEW_PRICING_ATTRIBUTE61;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE62 IS NULL AND C2.NEW_PRICING_ATTRIBUTE62 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE62 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE62 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE62 <> C2.NEW_PRICING_ATTRIBUTE62) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE62 := C2.NEW_PRICING_ATTRIBUTE62;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE63 IS NULL AND C2.NEW_PRICING_ATTRIBUTE63 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE63 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE63 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE63 <> C2.NEW_PRICING_ATTRIBUTE63) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE63 := C2.NEW_PRICING_ATTRIBUTE63;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE64 IS NULL AND C2.NEW_PRICING_ATTRIBUTE64 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE64 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE64 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE64 <> C2.NEW_PRICING_ATTRIBUTE64) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE64 := C2.NEW_PRICING_ATTRIBUTE64;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE65 IS NULL AND C2.NEW_PRICING_ATTRIBUTE65 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE65 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE65 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE65 <> C2.NEW_PRICING_ATTRIBUTE65) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE65 := C2.NEW_PRICING_ATTRIBUTE65;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE66 IS NULL AND C2.NEW_PRICING_ATTRIBUTE66 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE66 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE66 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE66 <> C2.NEW_PRICING_ATTRIBUTE66) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE66 := C2.NEW_PRICING_ATTRIBUTE66;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE67 IS NULL AND C2.NEW_PRICING_ATTRIBUTE67 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE67 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE67 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE67 <> C2.NEW_PRICING_ATTRIBUTE67) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE67 := C2.NEW_PRICING_ATTRIBUTE67;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE68 IS NULL AND C2.NEW_PRICING_ATTRIBUTE68 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE68 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE68 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE68 <> C2.NEW_PRICING_ATTRIBUTE68) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE68 := C2.NEW_PRICING_ATTRIBUTE68;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE69 IS NULL AND C2.NEW_PRICING_ATTRIBUTE69 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE69 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE69 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE69 <> C2.NEW_PRICING_ATTRIBUTE69) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE69 := C2.NEW_PRICING_ATTRIBUTE69;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE70 IS NULL AND C2.NEW_PRICING_ATTRIBUTE70 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE70 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE70 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE70 <> C2.NEW_PRICING_ATTRIBUTE70) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE70 := C2.NEW_PRICING_ATTRIBUTE70;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE71 IS NULL AND C2.NEW_PRICING_ATTRIBUTE71 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE71 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE71 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE71 <> C2.NEW_PRICING_ATTRIBUTE71) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE71 := C2.NEW_PRICING_ATTRIBUTE71;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE72 IS NULL AND C2.NEW_PRICING_ATTRIBUTE72 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE72 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE72 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE72 <> C2.NEW_PRICING_ATTRIBUTE72) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE72 := C2.NEW_PRICING_ATTRIBUTE72;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE73 IS NULL AND C2.NEW_PRICING_ATTRIBUTE73 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE73 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE73 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE73 <> C2.NEW_PRICING_ATTRIBUTE73) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE73 := C2.NEW_PRICING_ATTRIBUTE73;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE74 IS NULL AND C2.NEW_PRICING_ATTRIBUTE74 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE74 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE74 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE74 <> C2.NEW_PRICING_ATTRIBUTE74) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE74 := C2.NEW_PRICING_ATTRIBUTE74;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE75 IS NULL AND C2.NEW_PRICING_ATTRIBUTE75 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE75 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE75 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE75 <> C2.NEW_PRICING_ATTRIBUTE75) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE75 := C2.NEW_PRICING_ATTRIBUTE75;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE76 IS NULL AND C2.NEW_PRICING_ATTRIBUTE76 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE76 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE76 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE76 <> C2.NEW_PRICING_ATTRIBUTE76) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE76 := C2.NEW_PRICING_ATTRIBUTE76;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE77 IS NULL AND C2.NEW_PRICING_ATTRIBUTE77 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE77 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE77 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE77 <> C2.NEW_PRICING_ATTRIBUTE77) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE77 := C2.NEW_PRICING_ATTRIBUTE77;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE78 IS NULL AND C2.NEW_PRICING_ATTRIBUTE78 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE78 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE78 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE78 <> C2.NEW_PRICING_ATTRIBUTE78) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE78 := C2.NEW_PRICING_ATTRIBUTE78;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE79 IS NULL AND C2.NEW_PRICING_ATTRIBUTE79 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE79 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE79 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE79 <> C2.NEW_PRICING_ATTRIBUTE79) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE79 := C2.NEW_PRICING_ATTRIBUTE79;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE80 IS NULL AND C2.NEW_PRICING_ATTRIBUTE80 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE80 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE80 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE80 <> C2.NEW_PRICING_ATTRIBUTE80) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE80 := C2.NEW_PRICING_ATTRIBUTE80;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE81 IS NULL AND C2.NEW_PRICING_ATTRIBUTE81 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE81 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE81 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE81 <> C2.NEW_PRICING_ATTRIBUTE81) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE81 := C2.NEW_PRICING_ATTRIBUTE81;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE82 IS NULL AND C2.NEW_PRICING_ATTRIBUTE82 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE82 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE82 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE82 <> C2.NEW_PRICING_ATTRIBUTE82) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE82 := C2.NEW_PRICING_ATTRIBUTE82;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE83 IS NULL AND C2.NEW_PRICING_ATTRIBUTE83 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE83 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE83 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE83 <> C2.NEW_PRICING_ATTRIBUTE83) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE83 := C2.NEW_PRICING_ATTRIBUTE83;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE84 IS NULL AND C2.NEW_PRICING_ATTRIBUTE84 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE84 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE84 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE84 <> C2.NEW_PRICING_ATTRIBUTE84) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE84 := C2.NEW_PRICING_ATTRIBUTE84;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE85 IS NULL AND C2.NEW_PRICING_ATTRIBUTE85 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE85 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE85 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE85 <> C2.NEW_PRICING_ATTRIBUTE85) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE85 := C2.NEW_PRICING_ATTRIBUTE85;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE86 IS NULL AND C2.NEW_PRICING_ATTRIBUTE86 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE86 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE86 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE86 <> C2.NEW_PRICING_ATTRIBUTE86) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE86 := C2.NEW_PRICING_ATTRIBUTE86;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE87 IS NULL AND C2.NEW_PRICING_ATTRIBUTE87 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE87 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE87 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE87 <> C2.NEW_PRICING_ATTRIBUTE87) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE87 := C2.NEW_PRICING_ATTRIBUTE87;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE88 IS NULL AND C2.NEW_PRICING_ATTRIBUTE88 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE88 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE88 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE88 <> C2.NEW_PRICING_ATTRIBUTE88) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE88 := C2.NEW_PRICING_ATTRIBUTE88;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE89 IS NULL AND C2.NEW_PRICING_ATTRIBUTE89 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE89 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE89 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE89 <> C2.NEW_PRICING_ATTRIBUTE89) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE89 := C2.NEW_PRICING_ATTRIBUTE89;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE90 IS NULL AND C2.NEW_PRICING_ATTRIBUTE90 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE90 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE90 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE90 <> C2.NEW_PRICING_ATTRIBUTE90) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE90 := C2.NEW_PRICING_ATTRIBUTE90;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE91 IS NULL AND C2.NEW_PRICING_ATTRIBUTE91 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE91 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE91 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE91 <> C2.NEW_PRICING_ATTRIBUTE91) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE91 := C2.NEW_PRICING_ATTRIBUTE91;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE92 IS NULL AND C2.NEW_PRICING_ATTRIBUTE92 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE92 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE92 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE92 <> C2.NEW_PRICING_ATTRIBUTE92) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE92 := C2.NEW_PRICING_ATTRIBUTE92;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE93 IS NULL AND C2.NEW_PRICING_ATTRIBUTE93 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE93 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE93 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE93 <> C2.NEW_PRICING_ATTRIBUTE93) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE93 := C2.NEW_PRICING_ATTRIBUTE93;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE94 IS NULL AND C2.NEW_PRICING_ATTRIBUTE94 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE94 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE94 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE94 <> C2.NEW_PRICING_ATTRIBUTE94) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE94 := C2.NEW_PRICING_ATTRIBUTE94;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE95 IS NULL AND C2.NEW_PRICING_ATTRIBUTE95 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE95 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE95 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE95 <> C2.NEW_PRICING_ATTRIBUTE95) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE95 := C2.NEW_PRICING_ATTRIBUTE95;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE96 IS NULL AND C2.NEW_PRICING_ATTRIBUTE96 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE96 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE96 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE96 <> C2.NEW_PRICING_ATTRIBUTE96) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE96 := C2.NEW_PRICING_ATTRIBUTE96;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE97 IS NULL AND C2.NEW_PRICING_ATTRIBUTE97 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE97 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE97 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE97 <> C2.NEW_PRICING_ATTRIBUTE97) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE97 := C2.NEW_PRICING_ATTRIBUTE97;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE98 IS NULL AND C2.NEW_PRICING_ATTRIBUTE98 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE98 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE98 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE98 <> C2.NEW_PRICING_ATTRIBUTE98) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE98 := C2.NEW_PRICING_ATTRIBUTE98;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE99 IS NULL AND C2.NEW_PRICING_ATTRIBUTE99 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE99 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE99 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE99 <> C2.NEW_PRICING_ATTRIBUTE99) THEN
                l_pri_tbl(i).PRICING_ATTRIBUTE99 := C2.NEW_PRICING_ATTRIBUTE99;
           END IF;

           IF (C2.OLD_PRICING_ATTRIBUTE100 IS NULL AND C2.NEW_PRICING_ATTRIBUTE100 IS NOT NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE100 IS NOT NULL AND C2.NEW_PRICING_ATTRIBUTE100 IS NULL)
           OR (C2.OLD_PRICING_ATTRIBUTE100 <> C2.NEW_PRICING_ATTRIBUTE100) THEN
               l_pri_tbl(i).PRICING_ATTRIBUTE100 := C2.NEW_PRICING_ATTRIBUTE100;
           END IF;

           IF (C2.OLD_ACTIVE_START_DATE IS NULL AND C2.NEW_ACTIVE_START_DATE IS NOT NULL)
           OR (C2.OLD_ACTIVE_START_DATE IS NOT NULL AND C2.NEW_ACTIVE_START_DATE IS NULL)
           OR (C2.OLD_ACTIVE_START_DATE <> C2.NEW_ACTIVE_START_DATE ) THEN
                l_pri_tbl(i).ACTIVE_START_DATE := C2.NEW_ACTIVE_START_DATE;
           END IF;

           IF (C2.OLD_ACTIVE_END_DATE IS NULL AND C2.NEW_ACTIVE_END_DATE IS NOT NULL)
           OR (C2.OLD_ACTIVE_END_DATE IS NOT NULL AND C2.NEW_ACTIVE_END_DATE IS NULL)
           OR (C2.OLD_ACTIVE_END_DATE <> C2.NEW_ACTIVE_END_DATE) THEN
                l_pri_tbl(i).ACTIVE_END_DATE := C2.NEW_ACTIVE_END_DATE;
           END IF;

           IF (C2.OLD_CONTEXT IS NULL AND C2.NEW_CONTEXT IS NOT NULL)
           OR (C2.OLD_CONTEXT IS NOT NULL AND C2.NEW_CONTEXT IS NULL)
           OR (C2.OLD_CONTEXT <> C2.NEW_CONTEXT) THEN
                l_pri_tbl(i).CONTEXT := C2.NEW_CONTEXT;
           END IF;

           IF (C2.OLD_ATTRIBUTE1 IS NULL AND C2.NEW_ATTRIBUTE1 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE1 IS NOT NULL AND C2.NEW_ATTRIBUTE1 IS NULL)
           OR (C2.OLD_ATTRIBUTE1 <> C2.NEW_ATTRIBUTE1) THEN
                l_pri_tbl(i).ATTRIBUTE1 := C2.NEW_ATTRIBUTE1;
           END IF;

           IF (C2.OLD_ATTRIBUTE2 IS NULL AND C2.NEW_ATTRIBUTE2 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE2 IS NOT NULL AND C2.NEW_ATTRIBUTE2 IS NULL)
           OR (C2.OLD_ATTRIBUTE2 <> C2.NEW_ATTRIBUTE2) THEN
                l_pri_tbl(i).ATTRIBUTE2 := C2.NEW_ATTRIBUTE2;
           END IF;

           IF (C2.OLD_ATTRIBUTE3 IS NULL AND C2.NEW_ATTRIBUTE3 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE3 IS NOT NULL AND C2.NEW_ATTRIBUTE3 IS NULL)
           OR (C2.OLD_ATTRIBUTE3 <> C2.NEW_ATTRIBUTE3) THEN
                l_pri_tbl(i).ATTRIBUTE3 := C2.NEW_ATTRIBUTE3;
           END IF;

           IF (C2.OLD_ATTRIBUTE4 IS NULL AND C2.NEW_ATTRIBUTE4 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE4 IS NOT NULL AND C2.NEW_ATTRIBUTE4 IS NULL)
           OR (C2.OLD_ATTRIBUTE4 <> C2.NEW_ATTRIBUTE4) THEN
                l_pri_tbl(i).ATTRIBUTE3 := C2.NEW_ATTRIBUTE4;
           END IF;

           IF (C2.OLD_ATTRIBUTE5 IS NULL AND C2.NEW_ATTRIBUTE5 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE5 IS NOT NULL AND C2.NEW_ATTRIBUTE5 IS NULL)
           OR (C2.OLD_ATTRIBUTE5 <> C2.NEW_ATTRIBUTE5) THEN
                l_pri_tbl(i).ATTRIBUTE5 := C2.NEW_ATTRIBUTE5;
           END IF;

           IF (C2.OLD_ATTRIBUTE6 IS NULL AND C2.NEW_ATTRIBUTE6 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE6 IS NOT NULL AND C2.NEW_ATTRIBUTE6 IS NULL)
           OR (C2.OLD_ATTRIBUTE6 <> C2.NEW_ATTRIBUTE6) THEN
                l_pri_tbl(i).ATTRIBUTE6 := C2.NEW_ATTRIBUTE6;
           END IF;

           IF (C2.OLD_ATTRIBUTE7 IS NULL AND C2.NEW_ATTRIBUTE7 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE7 IS NOT NULL AND C2.NEW_ATTRIBUTE7 IS NULL)
           OR (C2.OLD_ATTRIBUTE7 <> C2.NEW_ATTRIBUTE7) THEN
                l_pri_tbl(i).ATTRIBUTE7 := C2.NEW_ATTRIBUTE7;
           END IF;

           IF (C2.OLD_ATTRIBUTE8 IS NULL AND C2.NEW_ATTRIBUTE8 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE8 IS NOT NULL AND C2.NEW_ATTRIBUTE8 IS NULL)
           OR (C2.OLD_ATTRIBUTE8 <> C2.NEW_ATTRIBUTE8) THEN
                l_pri_tbl(i).ATTRIBUTE8 := C2.NEW_ATTRIBUTE8;
           END IF;

           IF (C2.OLD_ATTRIBUTE9 IS NULL AND C2.NEW_ATTRIBUTE9 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE9 IS NOT NULL AND C2.NEW_ATTRIBUTE9 IS NULL)
           OR (C2.OLD_ATTRIBUTE9 <> C2.NEW_ATTRIBUTE9) THEN
                l_pri_tbl(i).ATTRIBUTE9 := C2.NEW_ATTRIBUTE9;
           END IF;

           IF (C2.OLD_ATTRIBUTE10 IS NULL AND C2.NEW_ATTRIBUTE10 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE10 IS NOT NULL AND C2.NEW_ATTRIBUTE10 IS NULL)
           OR (C2.OLD_ATTRIBUTE10 <> C2.NEW_ATTRIBUTE10) THEN
                l_pri_tbl(i).ATTRIBUTE10 := C2.NEW_ATTRIBUTE10;
           END IF;

           IF (C2.OLD_ATTRIBUTE11 IS NULL AND C2.NEW_ATTRIBUTE11 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE11 IS NOT NULL AND C2.NEW_ATTRIBUTE11 IS NULL)
           OR (C2.OLD_ATTRIBUTE11 <> C2.NEW_ATTRIBUTE11) THEN
                l_pri_tbl(i).ATTRIBUTE11 := C2.NEW_ATTRIBUTE11;
           END IF;

           IF (C2.OLD_ATTRIBUTE12 IS NULL AND C2.NEW_ATTRIBUTE12 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE12 IS NOT NULL AND C2.NEW_ATTRIBUTE12 IS NULL)
           OR (C2.OLD_ATTRIBUTE12 <> C2.NEW_ATTRIBUTE12) THEN
                l_pri_tbl(i).ATTRIBUTE12 := C2.NEW_ATTRIBUTE12;
           END IF;

           IF (C2.OLD_ATTRIBUTE13 IS NULL AND C2.NEW_ATTRIBUTE13 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE13 IS NOT NULL AND C2.NEW_ATTRIBUTE13 IS NULL)
           OR (C2.OLD_ATTRIBUTE13 <> C2.NEW_ATTRIBUTE13) THEN
                l_pri_tbl(i).ATTRIBUTE13 := C2.NEW_ATTRIBUTE13;
           END IF;

           IF (C2.OLD_ATTRIBUTE14 IS NULL AND C2.NEW_ATTRIBUTE14 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE14 IS NOT NULL AND C2.NEW_ATTRIBUTE14 IS NULL)
           OR (C2.OLD_ATTRIBUTE14 <> C2.NEW_ATTRIBUTE14) THEN
                l_pri_tbl(i).ATTRIBUTE14 := C2.NEW_ATTRIBUTE14;
           END IF;

           IF (C2.OLD_ATTRIBUTE15 IS NULL AND C2.NEW_ATTRIBUTE15 IS NOT NULL)
           OR (C2.OLD_ATTRIBUTE15 IS NOT NULL AND C2.NEW_ATTRIBUTE15 IS NULL)
           OR (C2.OLD_ATTRIBUTE15 <> C2.NEW_ATTRIBUTE15) THEN
                l_pri_tbl(i).ATTRIBUTE15 := C2.NEW_ATTRIBUTE15;
           END IF;
      END LOOP; --end loop for C2

     EXCEPTION
        WHEN Process_next THEN
           NULL;
     END;

    END LOOP; --end loop for C1
    --
    x_pri_tbl.DELETE;
    IF l_pri_tbl.count > 0 THEN
       FOR pri_row in l_pri_tbl.FIRST .. l_pri_tbl.LAST
       LOOP
          IF l_pri_tbl.EXISTS(pri_row) THEN
             l_pri_count := l_pri_count + 1;
             x_pri_tbl(l_pri_count) := l_pri_tbl(pri_row);
          END IF;
       END LOOP;
    END IF;

  END IF; --end if for l_pri_tbl > 0

END Construct_pri_from_hist;


/*----------------------------------------------------------*/
/* Procedure name:  Define_pri_Columns                     */
/* Description : This procudure gets the column values      */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/
PROCEDURE Define_pri_Columns
   (    p_get_pri_cursor_id      IN   NUMBER
    )
IS
    l_pri_rec                csi_datastructures_pub.pricing_attribs_rec;

BEGIN

    dbms_sql.define_column(p_get_pri_cursor_id, 1, l_pri_rec.PRICING_ATTRIBUTE_ID);
    dbms_sql.define_column(p_get_pri_cursor_id, 2, l_pri_rec.INSTANCE_ID);
    dbms_sql.define_column(p_get_pri_cursor_id, 3, l_pri_rec.ACTIVE_START_DATE);
    dbms_sql.define_column(p_get_pri_cursor_id, 4, l_pri_rec.ACTIVE_END_DATE);
    dbms_sql.define_column(p_get_pri_cursor_id, 5, l_pri_rec.PRICING_CONTEXT,30);
    dbms_sql.define_column(p_get_pri_cursor_id, 6, l_pri_rec.PRICING_ATTRIBUTE1,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 7, l_pri_rec.PRICING_ATTRIBUTE2,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 8, l_pri_rec.PRICING_ATTRIBUTE3,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 9, l_pri_rec.PRICING_ATTRIBUTE4,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 10, l_pri_rec.PRICING_ATTRIBUTE5,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 11, l_pri_rec.PRICING_ATTRIBUTE6,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 12, l_pri_rec.PRICING_ATTRIBUTE7,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 13, l_pri_rec.PRICING_ATTRIBUTE8,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 14, l_pri_rec.PRICING_ATTRIBUTE9,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 15, l_pri_rec.PRICING_ATTRIBUTE10,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 16, l_pri_rec.PRICING_ATTRIBUTE11,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 17, l_pri_rec.PRICING_ATTRIBUTE12,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 18, l_pri_rec.PRICING_ATTRIBUTE13,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 19, l_pri_rec.PRICING_ATTRIBUTE14,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 20, l_pri_rec.PRICING_ATTRIBUTE15,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 21, l_pri_rec.PRICING_ATTRIBUTE16,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 22, l_pri_rec.PRICING_ATTRIBUTE17,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 23, l_pri_rec.PRICING_ATTRIBUTE18,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 24, l_pri_rec.PRICING_ATTRIBUTE19,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 25, l_pri_rec.PRICING_ATTRIBUTE20,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 26, l_pri_rec.PRICING_ATTRIBUTE21,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 27, l_pri_rec.PRICING_ATTRIBUTE22,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 28, l_pri_rec.PRICING_ATTRIBUTE23,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 29, l_pri_rec.PRICING_ATTRIBUTE24,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 30, l_pri_rec.PRICING_ATTRIBUTE25,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 31, l_pri_rec.PRICING_ATTRIBUTE26,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 32, l_pri_rec.PRICING_ATTRIBUTE27,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 33, l_pri_rec.PRICING_ATTRIBUTE28,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 34, l_pri_rec.PRICING_ATTRIBUTE29,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 35, l_pri_rec.PRICING_ATTRIBUTE30,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 36, l_pri_rec.PRICING_ATTRIBUTE31,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 37, l_pri_rec.PRICING_ATTRIBUTE32,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 38, l_pri_rec.PRICING_ATTRIBUTE33,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 39, l_pri_rec.PRICING_ATTRIBUTE34,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 40, l_pri_rec.PRICING_ATTRIBUTE35,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 41, l_pri_rec.PRICING_ATTRIBUTE36,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 42, l_pri_rec.PRICING_ATTRIBUTE37,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 43, l_pri_rec.PRICING_ATTRIBUTE38,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 44, l_pri_rec.PRICING_ATTRIBUTE39,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 45, l_pri_rec.PRICING_ATTRIBUTE40,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 46, l_pri_rec.PRICING_ATTRIBUTE41,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 47, l_pri_rec.PRICING_ATTRIBUTE42,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 48, l_pri_rec.PRICING_ATTRIBUTE43,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 49, l_pri_rec.PRICING_ATTRIBUTE44,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 50, l_pri_rec.PRICING_ATTRIBUTE45,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 51, l_pri_rec.PRICING_ATTRIBUTE46,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 52, l_pri_rec.PRICING_ATTRIBUTE47,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 53, l_pri_rec.PRICING_ATTRIBUTE48,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 54, l_pri_rec.PRICING_ATTRIBUTE49,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 55, l_pri_rec.PRICING_ATTRIBUTE50,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 56, l_pri_rec.PRICING_ATTRIBUTE51,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 57, l_pri_rec.PRICING_ATTRIBUTE52,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 58, l_pri_rec.PRICING_ATTRIBUTE53,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 59, l_pri_rec.PRICING_ATTRIBUTE54,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 60, l_pri_rec.PRICING_ATTRIBUTE55,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 61, l_pri_rec.PRICING_ATTRIBUTE56,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 62, l_pri_rec.PRICING_ATTRIBUTE57,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 63, l_pri_rec.PRICING_ATTRIBUTE58,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 64, l_pri_rec.PRICING_ATTRIBUTE59,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 65, l_pri_rec.PRICING_ATTRIBUTE60,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 66, l_pri_rec.PRICING_ATTRIBUTE61,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 67, l_pri_rec.PRICING_ATTRIBUTE62,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 68, l_pri_rec.PRICING_ATTRIBUTE63,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 69, l_pri_rec.PRICING_ATTRIBUTE64,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 70, l_pri_rec.PRICING_ATTRIBUTE65,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 71, l_pri_rec.PRICING_ATTRIBUTE66,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 72, l_pri_rec.PRICING_ATTRIBUTE67,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 73, l_pri_rec.PRICING_ATTRIBUTE68,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 74, l_pri_rec.PRICING_ATTRIBUTE69,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 75, l_pri_rec.PRICING_ATTRIBUTE70,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 76, l_pri_rec.PRICING_ATTRIBUTE71,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 77, l_pri_rec.PRICING_ATTRIBUTE72,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 78, l_pri_rec.PRICING_ATTRIBUTE73,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 79, l_pri_rec.PRICING_ATTRIBUTE74,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 80, l_pri_rec.PRICING_ATTRIBUTE75,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 81, l_pri_rec.PRICING_ATTRIBUTE76,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 82, l_pri_rec.PRICING_ATTRIBUTE77,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 83, l_pri_rec.PRICING_ATTRIBUTE78,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 84, l_pri_rec.PRICING_ATTRIBUTE79,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 85, l_pri_rec.PRICING_ATTRIBUTE80,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 86, l_pri_rec.PRICING_ATTRIBUTE81,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 87, l_pri_rec.PRICING_ATTRIBUTE82,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 88, l_pri_rec.PRICING_ATTRIBUTE83,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 89, l_pri_rec.PRICING_ATTRIBUTE84,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 90, l_pri_rec.PRICING_ATTRIBUTE85,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 91, l_pri_rec.PRICING_ATTRIBUTE86,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 92, l_pri_rec.PRICING_ATTRIBUTE87,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 93, l_pri_rec.PRICING_ATTRIBUTE88,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 94, l_pri_rec.PRICING_ATTRIBUTE89,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 95, l_pri_rec.PRICING_ATTRIBUTE90,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 96, l_pri_rec.PRICING_ATTRIBUTE91,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 97, l_pri_rec.PRICING_ATTRIBUTE92,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 98, l_pri_rec.PRICING_ATTRIBUTE93,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 99, l_pri_rec.PRICING_ATTRIBUTE94,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 100, l_pri_rec.PRICING_ATTRIBUTE95,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 101, l_pri_rec.PRICING_ATTRIBUTE96,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 102, l_pri_rec.PRICING_ATTRIBUTE97,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 103, l_pri_rec.PRICING_ATTRIBUTE98,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 104, l_pri_rec.PRICING_ATTRIBUTE99,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 105, l_pri_rec.PRICING_ATTRIBUTE100,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 106, l_pri_rec.CONTEXT,30);
    dbms_sql.define_column(p_get_pri_cursor_id, 107, l_pri_rec.ATTRIBUTE1,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 108, l_pri_rec.ATTRIBUTE2,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 109, l_pri_rec.ATTRIBUTE3,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 110, l_pri_rec.ATTRIBUTE4,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 111, l_pri_rec.ATTRIBUTE5,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 112, l_pri_rec.ATTRIBUTE6,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 113, l_pri_rec.ATTRIBUTE7,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 114, l_pri_rec.ATTRIBUTE8,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 115, l_pri_rec.ATTRIBUTE9,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 116, l_pri_rec.ATTRIBUTE10,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 117, l_pri_rec.ATTRIBUTE11,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 118, l_pri_rec.ATTRIBUTE12,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 119, l_pri_rec.ATTRIBUTE13,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 120, l_pri_rec.ATTRIBUTE14,150);
    dbms_sql.define_column(p_get_pri_cursor_id, 121, l_pri_rec.ATTRIBUTE15,150);
 -- dbms_sql.define_column(p_get_pri_cursor_id, 122, l_pri_rec.CREATED_BY);
 -- dbms_sql.define_column(p_get_pri_cursor_id, 123, l_pri_rec.CREATION_DATE);
 -- dbms_sql.define_column(p_get_pri_cursor_id, 124, l_pri_rec.LAST_UPDATED_BY );
 -- dbms_sql.define_column(p_get_pri_cursor_id, 125, l_pri_rec.LAST_UPDATE_DATE);
 -- dbms_sql.define_column(p_get_pri_cursor_id, 126, l_pri_rec.LAST_UPDATE_LOGIN);
    dbms_sql.define_column(p_get_pri_cursor_id, 127, l_pri_rec.OBJECT_VERSION_NUMBER);

END Define_pri_Columns;

/*----------------------------------------------------------*/
/* Procedure name:  Get_pri_Column_Values                    */
/* Description : This procudure gets the column values      */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Get_pri_Column_Values
   (p_get_pri_cursor_id      IN   NUMBER,
    x_pri_rec                OUT NOCOPY  csi_datastructures_pub.pricing_attribs_rec
    ) IS

BEGIN

    dbms_sql.column_value(p_get_pri_cursor_id, 1, x_pri_rec.PRICING_ATTRIBUTE_ID);
    dbms_sql.column_value(p_get_pri_cursor_id, 2, x_pri_rec.INSTANCE_ID);
    dbms_sql.column_value(p_get_pri_cursor_id, 3, x_pri_rec.ACTIVE_START_DATE);
    dbms_sql.column_value(p_get_pri_cursor_id, 4, x_pri_rec.ACTIVE_END_DATE);
    dbms_sql.column_value(p_get_pri_cursor_id, 5, x_pri_rec.PRICING_CONTEXT);
    dbms_sql.column_value(p_get_pri_cursor_id, 6, x_pri_rec.PRICING_ATTRIBUTE1);
    dbms_sql.column_value(p_get_pri_cursor_id, 7, x_pri_rec.PRICING_ATTRIBUTE2);
    dbms_sql.column_value(p_get_pri_cursor_id, 8, x_pri_rec.PRICING_ATTRIBUTE3);
    dbms_sql.column_value(p_get_pri_cursor_id, 9, x_pri_rec.PRICING_ATTRIBUTE4);
    dbms_sql.column_value(p_get_pri_cursor_id, 10, x_pri_rec.PRICING_ATTRIBUTE5);
    dbms_sql.column_value(p_get_pri_cursor_id, 11, x_pri_rec.PRICING_ATTRIBUTE6);
    dbms_sql.column_value(p_get_pri_cursor_id, 12, x_pri_rec.PRICING_ATTRIBUTE7);
    dbms_sql.column_value(p_get_pri_cursor_id, 13, x_pri_rec.PRICING_ATTRIBUTE8);
    dbms_sql.column_value(p_get_pri_cursor_id, 14, x_pri_rec.PRICING_ATTRIBUTE9);
    dbms_sql.column_value(p_get_pri_cursor_id, 15, x_pri_rec.PRICING_ATTRIBUTE10);
    dbms_sql.column_value(p_get_pri_cursor_id, 16, x_pri_rec.PRICING_ATTRIBUTE11);
    dbms_sql.column_value(p_get_pri_cursor_id, 17, x_pri_rec.PRICING_ATTRIBUTE12);
    dbms_sql.column_value(p_get_pri_cursor_id, 18, x_pri_rec.PRICING_ATTRIBUTE13);
    dbms_sql.column_value(p_get_pri_cursor_id, 19, x_pri_rec.PRICING_ATTRIBUTE14);
    dbms_sql.column_value(p_get_pri_cursor_id, 20, x_pri_rec.PRICING_ATTRIBUTE15);
    dbms_sql.column_value(p_get_pri_cursor_id, 21, x_pri_rec.PRICING_ATTRIBUTE16);
    dbms_sql.column_value(p_get_pri_cursor_id, 22, x_pri_rec.PRICING_ATTRIBUTE17);
    dbms_sql.column_value(p_get_pri_cursor_id, 23, x_pri_rec.PRICING_ATTRIBUTE18);
    dbms_sql.column_value(p_get_pri_cursor_id, 24, x_pri_rec.PRICING_ATTRIBUTE19);
    dbms_sql.column_value(p_get_pri_cursor_id, 25, x_pri_rec.PRICING_ATTRIBUTE20);
    dbms_sql.column_value(p_get_pri_cursor_id, 26, x_pri_rec.PRICING_ATTRIBUTE21);
    dbms_sql.column_value(p_get_pri_cursor_id, 27, x_pri_rec.PRICING_ATTRIBUTE22);
    dbms_sql.column_value(p_get_pri_cursor_id, 28, x_pri_rec.PRICING_ATTRIBUTE23);
    dbms_sql.column_value(p_get_pri_cursor_id, 29, x_pri_rec.PRICING_ATTRIBUTE24);
    dbms_sql.column_value(p_get_pri_cursor_id, 30, x_pri_rec.PRICING_ATTRIBUTE25);
    dbms_sql.column_value(p_get_pri_cursor_id, 31, x_pri_rec.PRICING_ATTRIBUTE26);
    dbms_sql.column_value(p_get_pri_cursor_id, 32, x_pri_rec.PRICING_ATTRIBUTE27);
    dbms_sql.column_value(p_get_pri_cursor_id, 33, x_pri_rec.PRICING_ATTRIBUTE28);
    dbms_sql.column_value(p_get_pri_cursor_id, 34, x_pri_rec.PRICING_ATTRIBUTE29);
    dbms_sql.column_value(p_get_pri_cursor_id, 35, x_pri_rec.PRICING_ATTRIBUTE30);
    dbms_sql.column_value(p_get_pri_cursor_id, 36, x_pri_rec.PRICING_ATTRIBUTE31);
    dbms_sql.column_value(p_get_pri_cursor_id, 37, x_pri_rec.PRICING_ATTRIBUTE32);
    dbms_sql.column_value(p_get_pri_cursor_id, 38, x_pri_rec.PRICING_ATTRIBUTE33);
    dbms_sql.column_value(p_get_pri_cursor_id, 39, x_pri_rec.PRICING_ATTRIBUTE34);
    dbms_sql.column_value(p_get_pri_cursor_id, 40, x_pri_rec.PRICING_ATTRIBUTE35);
    dbms_sql.column_value(p_get_pri_cursor_id, 41, x_pri_rec.PRICING_ATTRIBUTE36);
    dbms_sql.column_value(p_get_pri_cursor_id, 42, x_pri_rec.PRICING_ATTRIBUTE37);
    dbms_sql.column_value(p_get_pri_cursor_id, 43, x_pri_rec.PRICING_ATTRIBUTE38);
    dbms_sql.column_value(p_get_pri_cursor_id, 44, x_pri_rec.PRICING_ATTRIBUTE39);
    dbms_sql.column_value(p_get_pri_cursor_id, 45, x_pri_rec.PRICING_ATTRIBUTE40);
    dbms_sql.column_value(p_get_pri_cursor_id, 46, x_pri_rec.PRICING_ATTRIBUTE41);
    dbms_sql.column_value(p_get_pri_cursor_id, 47, x_pri_rec.PRICING_ATTRIBUTE42);
    dbms_sql.column_value(p_get_pri_cursor_id, 48, x_pri_rec.PRICING_ATTRIBUTE43);
    dbms_sql.column_value(p_get_pri_cursor_id, 49, x_pri_rec.PRICING_ATTRIBUTE44);
    dbms_sql.column_value(p_get_pri_cursor_id, 50, x_pri_rec.PRICING_ATTRIBUTE45);
    dbms_sql.column_value(p_get_pri_cursor_id, 51, x_pri_rec.PRICING_ATTRIBUTE46);
    dbms_sql.column_value(p_get_pri_cursor_id, 52, x_pri_rec.PRICING_ATTRIBUTE47);
    dbms_sql.column_value(p_get_pri_cursor_id, 53, x_pri_rec.PRICING_ATTRIBUTE48);
    dbms_sql.column_value(p_get_pri_cursor_id, 54, x_pri_rec.PRICING_ATTRIBUTE49);
    dbms_sql.column_value(p_get_pri_cursor_id, 55, x_pri_rec.PRICING_ATTRIBUTE50);
    dbms_sql.column_value(p_get_pri_cursor_id, 56, x_pri_rec.PRICING_ATTRIBUTE51);
    dbms_sql.column_value(p_get_pri_cursor_id, 57, x_pri_rec.PRICING_ATTRIBUTE52);
    dbms_sql.column_value(p_get_pri_cursor_id, 58, x_pri_rec.PRICING_ATTRIBUTE53);
    dbms_sql.column_value(p_get_pri_cursor_id, 59, x_pri_rec.PRICING_ATTRIBUTE54);
    dbms_sql.column_value(p_get_pri_cursor_id, 60, x_pri_rec.PRICING_ATTRIBUTE55);
    dbms_sql.column_value(p_get_pri_cursor_id, 61, x_pri_rec.PRICING_ATTRIBUTE56);
    dbms_sql.column_value(p_get_pri_cursor_id, 62, x_pri_rec.PRICING_ATTRIBUTE57);
    dbms_sql.column_value(p_get_pri_cursor_id, 63, x_pri_rec.PRICING_ATTRIBUTE58);
    dbms_sql.column_value(p_get_pri_cursor_id, 64, x_pri_rec.PRICING_ATTRIBUTE59);
    dbms_sql.column_value(p_get_pri_cursor_id, 65, x_pri_rec.PRICING_ATTRIBUTE60);
    dbms_sql.column_value(p_get_pri_cursor_id, 66, x_pri_rec.PRICING_ATTRIBUTE61);
    dbms_sql.column_value(p_get_pri_cursor_id, 67, x_pri_rec.PRICING_ATTRIBUTE62);
    dbms_sql.column_value(p_get_pri_cursor_id, 68, x_pri_rec.PRICING_ATTRIBUTE63);
    dbms_sql.column_value(p_get_pri_cursor_id, 69, x_pri_rec.PRICING_ATTRIBUTE64);
    dbms_sql.column_value(p_get_pri_cursor_id, 70, x_pri_rec.PRICING_ATTRIBUTE65);
    dbms_sql.column_value(p_get_pri_cursor_id, 71, x_pri_rec.PRICING_ATTRIBUTE66);
    dbms_sql.column_value(p_get_pri_cursor_id, 72, x_pri_rec.PRICING_ATTRIBUTE67);
    dbms_sql.column_value(p_get_pri_cursor_id, 73, x_pri_rec.PRICING_ATTRIBUTE68);
    dbms_sql.column_value(p_get_pri_cursor_id, 74, x_pri_rec.PRICING_ATTRIBUTE69);
    dbms_sql.column_value(p_get_pri_cursor_id, 75, x_pri_rec.PRICING_ATTRIBUTE70);
    dbms_sql.column_value(p_get_pri_cursor_id, 76, x_pri_rec.PRICING_ATTRIBUTE71);
    dbms_sql.column_value(p_get_pri_cursor_id, 77, x_pri_rec.PRICING_ATTRIBUTE72);
    dbms_sql.column_value(p_get_pri_cursor_id, 78, x_pri_rec.PRICING_ATTRIBUTE73);
    dbms_sql.column_value(p_get_pri_cursor_id, 79, x_pri_rec.PRICING_ATTRIBUTE74);
    dbms_sql.column_value(p_get_pri_cursor_id, 80, x_pri_rec.PRICING_ATTRIBUTE75);
    dbms_sql.column_value(p_get_pri_cursor_id, 81, x_pri_rec.PRICING_ATTRIBUTE76);
    dbms_sql.column_value(p_get_pri_cursor_id, 82, x_pri_rec.PRICING_ATTRIBUTE77);
    dbms_sql.column_value(p_get_pri_cursor_id, 83, x_pri_rec.PRICING_ATTRIBUTE78);
    dbms_sql.column_value(p_get_pri_cursor_id, 84, x_pri_rec.PRICING_ATTRIBUTE79);
    dbms_sql.column_value(p_get_pri_cursor_id, 85, x_pri_rec.PRICING_ATTRIBUTE80);
    dbms_sql.column_value(p_get_pri_cursor_id, 86, x_pri_rec.PRICING_ATTRIBUTE81);
    dbms_sql.column_value(p_get_pri_cursor_id, 87, x_pri_rec.PRICING_ATTRIBUTE82);
    dbms_sql.column_value(p_get_pri_cursor_id, 88, x_pri_rec.PRICING_ATTRIBUTE83);
    dbms_sql.column_value(p_get_pri_cursor_id, 89, x_pri_rec.PRICING_ATTRIBUTE84);
    dbms_sql.column_value(p_get_pri_cursor_id, 90, x_pri_rec.PRICING_ATTRIBUTE85);
    dbms_sql.column_value(p_get_pri_cursor_id, 91, x_pri_rec.PRICING_ATTRIBUTE86);
    dbms_sql.column_value(p_get_pri_cursor_id, 92, x_pri_rec.PRICING_ATTRIBUTE87);
    dbms_sql.column_value(p_get_pri_cursor_id, 93, x_pri_rec.PRICING_ATTRIBUTE88);
    dbms_sql.column_value(p_get_pri_cursor_id, 94, x_pri_rec.PRICING_ATTRIBUTE89);
    dbms_sql.column_value(p_get_pri_cursor_id, 95, x_pri_rec.PRICING_ATTRIBUTE90);
    dbms_sql.column_value(p_get_pri_cursor_id, 96, x_pri_rec.PRICING_ATTRIBUTE91);
    dbms_sql.column_value(p_get_pri_cursor_id, 97, x_pri_rec.PRICING_ATTRIBUTE92);
    dbms_sql.column_value(p_get_pri_cursor_id, 98, x_pri_rec.PRICING_ATTRIBUTE93);
    dbms_sql.column_value(p_get_pri_cursor_id, 99, x_pri_rec.PRICING_ATTRIBUTE94);
    dbms_sql.column_value(p_get_pri_cursor_id, 100, x_pri_rec.PRICING_ATTRIBUTE95);
    dbms_sql.column_value(p_get_pri_cursor_id, 101, x_pri_rec.PRICING_ATTRIBUTE96);
    dbms_sql.column_value(p_get_pri_cursor_id, 102, x_pri_rec.PRICING_ATTRIBUTE97);
    dbms_sql.column_value(p_get_pri_cursor_id, 103, x_pri_rec.PRICING_ATTRIBUTE98);
    dbms_sql.column_value(p_get_pri_cursor_id, 104, x_pri_rec.PRICING_ATTRIBUTE99);
    dbms_sql.column_value(p_get_pri_cursor_id, 105, x_pri_rec.PRICING_ATTRIBUTE100);
    dbms_sql.column_value(p_get_pri_cursor_id, 106, x_pri_rec.CONTEXT);
    dbms_sql.column_value(p_get_pri_cursor_id, 107, x_pri_rec.ATTRIBUTE1);
    dbms_sql.column_value(p_get_pri_cursor_id, 108, x_pri_rec.ATTRIBUTE2);
    dbms_sql.column_value(p_get_pri_cursor_id, 109, x_pri_rec.ATTRIBUTE3);
    dbms_sql.column_value(p_get_pri_cursor_id, 110, x_pri_rec.ATTRIBUTE4);
    dbms_sql.column_value(p_get_pri_cursor_id, 111, x_pri_rec.ATTRIBUTE5);
    dbms_sql.column_value(p_get_pri_cursor_id, 112, x_pri_rec.ATTRIBUTE6);
    dbms_sql.column_value(p_get_pri_cursor_id, 113, x_pri_rec.ATTRIBUTE7);
    dbms_sql.column_value(p_get_pri_cursor_id, 114, x_pri_rec.ATTRIBUTE8);
    dbms_sql.column_value(p_get_pri_cursor_id, 115, x_pri_rec.ATTRIBUTE9);
    dbms_sql.column_value(p_get_pri_cursor_id, 116, x_pri_rec.ATTRIBUTE10);
    dbms_sql.column_value(p_get_pri_cursor_id, 117, x_pri_rec.ATTRIBUTE11);
    dbms_sql.column_value(p_get_pri_cursor_id, 118, x_pri_rec.ATTRIBUTE12);
    dbms_sql.column_value(p_get_pri_cursor_id, 119, x_pri_rec.ATTRIBUTE13);
    dbms_sql.column_value(p_get_pri_cursor_id, 120, x_pri_rec.ATTRIBUTE14);
    dbms_sql.column_value(p_get_pri_cursor_id, 121, x_pri_rec.ATTRIBUTE15);
 -- dbms_sql.column_value(p_get_pri_cursor_id, 122, x_pri_rec.CREATED_BY);
 -- dbms_sql.column_value(p_get_pri_cursor_id, 123, x_pri_rec.CREATION_DATE);
 -- dbms_sql.column_value(p_get_pri_cursor_id, 124, x_pri_rec.LAST_UPDATED_BY );
 -- dbms_sql.column_value(p_get_pri_cursor_id, 125, x_pri_rec.LAST_UPDATE_DATE);
 -- dbms_sql.column_value(p_get_pri_cursor_id, 126, x_pri_rec.LAST_UPDATE_LOGIN);
    dbms_sql.column_value(p_get_pri_cursor_id, 127, x_pri_rec.OBJECT_VERSION_NUMBER);

END Get_pri_Column_Values;

/*----------------------------------------------------------*/
/* Procedure name:  Bind_pri_variable                       */
/* Description : This procudure binds the column values     */
/*                        for the Dynamic SQL               */
/*----------------------------------------------------------*/

PROCEDURE Bind_pri_variable
  ( p_pri_query_rec    IN    csi_datastructures_pub.pricing_attribs_query_rec,
    p_cur_get_pri      IN    NUMBER
   )
     IS
BEGIN
    IF( (p_pri_query_rec.pricing_attribute_id IS NOT NULL)
      AND (p_pri_query_rec.pricing_attribute_id  <> FND_API.G_MISS_NUM))  THEN
        DBMS_SQL.BIND_VARIABLE(p_cur_get_pri, ':pricing_attribute_id', p_pri_query_rec.pricing_attribute_id);
    END IF;

    IF( (p_pri_query_rec.instance_id IS NOT NULL)
      AND (p_pri_query_rec.instance_id <> FND_API.G_MISS_NUM))  THEN
        DBMS_SQL.BIND_VARIABLE(p_cur_get_pri, ':instance_id', p_pri_query_rec.instance_id);
    END IF;

END Bind_pri_variable;

/*----------------------------------------------------------*/
/* Procedure name:  Gen_pri_Where_Clause                    */
/* Description : Procedure used to  generate the where      */
/*                clause  for Extended Attributes units     */
/*----------------------------------------------------------*/

PROCEDURE Gen_pri_Where_Clause
( p_pri_query_rec       IN    csi_datastructures_pub.pricing_attribs_query_rec
   ,x_where_clause       OUT NOCOPY   VARCHAR2
 ) IS

BEGIN

  -- Assign null at the start
  x_where_clause := '';

  IF (( p_pri_query_rec.pricing_attribute_id  IS NOT NULL)  AND
       ( p_pri_query_rec.pricing_attribute_id <> FND_API.G_MISS_NUM)) THEN
        x_where_clause := ' pricing_attribute_id = :pricing_attribute_id ';
  ELSIF ( p_pri_query_rec.pricing_attribute_id  IS NULL)  THEN
        x_where_clause := ' pricing_attribute_id IS NULL ';
  END IF;

  IF ((p_pri_query_rec.instance_id IS NOT NULL)       AND
       (p_pri_query_rec.instance_id <> FND_API.G_MISS_NUM))   THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' instance_id = :instance_id ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' instance_id = :instance_id ';
        END IF;
  ELSIF (p_pri_query_rec.instance_id IS NULL) THEN
        IF x_where_clause IS NULL THEN
            x_where_clause := ' instance_id IS NULL ';
        ELSE
            x_where_clause := x_where_clause||' AND '||' instance_id IS NULL ';
        END IF;
  END IF;

END Gen_pri_Where_Clause;


/*------------------------------------------------------*/
/* procedure name: create_pricing_attribs              */
/* description :  Associates pricing attributes to an   */
/*                item instance                         */
/*------------------------------------------------------*/

PROCEDURE create_pricing_attribs
 (    p_api_version         IN       NUMBER
     ,p_commit              IN       VARCHAR2
     ,p_init_msg_list       IN       VARCHAR2
     ,p_validation_level    IN       NUMBER
     ,p_pricing_attribs_rec IN   OUT NOCOPY  csi_datastructures_pub.pricing_attribs_rec
     ,p_txn_rec             IN   OUT NOCOPY  csi_datastructures_pub.transaction_rec
     ,x_return_status            OUT NOCOPY VARCHAR2
     ,x_msg_count                OUT NOCOPY NUMBER
     ,x_msg_data                 OUT NOCOPY VARCHAR2
     ,p_called_from_grp     IN   VARCHAR2
 )

IS
    l_api_name                CONSTANT VARCHAR2(30) := 'create_pricing_attribs';
    l_api_version             CONSTANT NUMBER       := 1.0;
    l_debug_level                      NUMBER;
    l_msg_index                        NUMBER;
    l_msg_count                        NUMBER;
    l_pricing_attrib_id                NUMBER       :=  p_pricing_attribs_rec.pricing_attribute_id;
    l_pricing_attrib_h_id              NUMBER;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT      create_pricing_attribs;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name ,
                                        g_pkg_name)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Check the profile option debug_level for debug message reporting
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'create_pricing_attribs');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
          csi_gen_utility_pvt.put_line(
                             p_api_version  ||'-'
                         || p_commit        ||'-'
                         || p_init_msg_list ||'-'
                         || p_validation_level );
     -- Dump pricing_attribs_rec
          csi_gen_utility_pvt.dump_pricing_attribs_rec(p_pricing_attribs_rec);
     -- Dump txn_rec
          csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
    END IF;


    -- Start API body
    -- Verify if instance id is ok
    IF p_called_from_grp <> FND_API.G_TRUE THEN
       IF NOT(csi_pricing_attrib_vld_pvt.Is_valid_instance_id
               (p_pricing_attribs_rec.instance_id,
                'INSERT')) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;


   -- Check start effective date
    IF p_called_from_grp <> FND_API.G_TRUE THEN
       IF NOT(csi_pricing_attrib_vld_pvt.Is_StartDate_Valid
                        (p_pricing_attribs_rec.ACTIVE_START_DATE,
                           p_pricing_attribs_rec.ACTIVE_END_DATE ,
                           p_pricing_attribs_rec.INSTANCE_ID )) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;


   -- Check end effective date
    IF p_called_from_grp <> FND_API.G_TRUE THEN
       IF p_pricing_attribs_rec.ACTIVE_END_DATE is NOT NULL THEN
          IF NOT(csi_pricing_attrib_vld_pvt.Is_EndDate_Valid
                  (p_pricing_attribs_rec.ACTIVE_START_DATE,
                   p_pricing_attribs_rec.ACTIVE_END_DATE ,
                   p_pricing_attribs_rec.INSTANCE_ID ,
	           p_pricing_attribs_rec.PRICING_ATTRIBUTE_ID ,
                   p_txn_rec.TRANSACTION_ID))  THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
    END IF;


    -- If the pricing_attribute_id passed is null then generate from sequence
    -- and check if the value exists . If exists then generate again from the sequence
    -- till we get a value that does not exist
    IF l_pricing_attrib_id IS NULL OR
       l_pricing_attrib_id = FND_API.G_MISS_NUM THEN
       l_pricing_attrib_id:= csi_pricing_attrib_vld_pvt.get_pricing_attrib_id;
       p_pricing_attribs_rec.pricing_attribute_id := l_pricing_attrib_id;
       WHILE NOT(csi_pricing_attrib_vld_pvt.Is_valid_pricing_attrib_id
           (l_pricing_attrib_id))
       LOOP
          l_pricing_attrib_id := csi_pricing_attrib_vld_pvt.get_pricing_attrib_id;
          p_pricing_attribs_rec.pricing_attribute_id := l_pricing_attrib_id;
       END LOOP;
    ELSE
        -- Validate pricing_attribute_id
        IF NOT(csi_pricing_attrib_vld_pvt.Is_valid_pricing_attrib_id
           (p_pricing_attribs_rec.pricing_attribute_id)) THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
    --
    IF p_called_from_grp <> FND_API.G_TRUE THEN
       CSI_I_PRICING_ATTRIBS_PKG.Insert_Row
                  (
                  l_pricing_attrib_id
                  ,p_pricing_attribs_rec.instance_id
                  ,p_pricing_attribs_rec.active_start_date
                  ,p_pricing_attribs_rec.active_end_date
                  ,p_pricing_attribs_rec.context
                  ,p_pricing_attribs_rec.attribute1
                  ,p_pricing_attribs_rec.attribute2
                  ,p_pricing_attribs_rec.attribute3
                  ,p_pricing_attribs_rec.attribute4
                  ,p_pricing_attribs_rec.attribute5
                  ,p_pricing_attribs_rec.attribute6
                  ,p_pricing_attribs_rec.attribute7
                  ,p_pricing_attribs_rec.attribute8
                  ,p_pricing_attribs_rec.attribute9
                  ,p_pricing_attribs_rec.attribute10
                  ,p_pricing_attribs_rec.attribute11
                  ,p_pricing_attribs_rec.attribute12
                  ,p_pricing_attribs_rec.attribute13
                  ,p_pricing_attribs_rec.attribute14
                  ,p_pricing_attribs_rec.attribute15
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,1
                  ,p_pricing_attribs_rec.pricing_context
                  ,p_pricing_attribs_rec.pricing_attribute1
                  ,p_pricing_attribs_rec.pricing_attribute2
                  ,p_pricing_attribs_rec.pricing_attribute3
                  ,p_pricing_attribs_rec.pricing_attribute4
                  ,p_pricing_attribs_rec.pricing_attribute5
                  ,p_pricing_attribs_rec.pricing_attribute6
                  ,p_pricing_attribs_rec.pricing_attribute7
                  ,p_pricing_attribs_rec.pricing_attribute8
                  ,p_pricing_attribs_rec.pricing_attribute9
                  ,p_pricing_attribs_rec.pricing_attribute10
                  ,p_pricing_attribs_rec.pricing_attribute11
                  ,p_pricing_attribs_rec.pricing_attribute12
                  ,p_pricing_attribs_rec.pricing_attribute13
                  ,p_pricing_attribs_rec.pricing_attribute14
                  ,p_pricing_attribs_rec.pricing_attribute15
                  ,p_pricing_attribs_rec.pricing_attribute16
                  ,p_pricing_attribs_rec.pricing_attribute17
                  ,p_pricing_attribs_rec.pricing_attribute18
                  ,p_pricing_attribs_rec.pricing_attribute19
                  ,p_pricing_attribs_rec.pricing_attribute20
                  ,p_pricing_attribs_rec.pricing_attribute21
                  ,p_pricing_attribs_rec.pricing_attribute22
                  ,p_pricing_attribs_rec.pricing_attribute23
                  ,p_pricing_attribs_rec.pricing_attribute24
                  ,p_pricing_attribs_rec.pricing_attribute25
                  ,p_pricing_attribs_rec.pricing_attribute26
                  ,p_pricing_attribs_rec.pricing_attribute27
                  ,p_pricing_attribs_rec.pricing_attribute28
                  ,p_pricing_attribs_rec.pricing_attribute29
                  ,p_pricing_attribs_rec.pricing_attribute30
                  ,p_pricing_attribs_rec.pricing_attribute31
                  ,p_pricing_attribs_rec.pricing_attribute32
                  ,p_pricing_attribs_rec.pricing_attribute33
                  ,p_pricing_attribs_rec.pricing_attribute34
                  ,p_pricing_attribs_rec.pricing_attribute35
                  ,p_pricing_attribs_rec.pricing_attribute36
                  ,p_pricing_attribs_rec.pricing_attribute37
                  ,p_pricing_attribs_rec.pricing_attribute38
                  ,p_pricing_attribs_rec.pricing_attribute39
                  ,p_pricing_attribs_rec.pricing_attribute40
                  ,p_pricing_attribs_rec.pricing_attribute41
                  ,p_pricing_attribs_rec.pricing_attribute42
                  ,p_pricing_attribs_rec.pricing_attribute43
                  ,p_pricing_attribs_rec.pricing_attribute44
                  ,p_pricing_attribs_rec.pricing_attribute45
                  ,p_pricing_attribs_rec.pricing_attribute46
                  ,p_pricing_attribs_rec.pricing_attribute47
                  ,p_pricing_attribs_rec.pricing_attribute48
                  ,p_pricing_attribs_rec.pricing_attribute49
                  ,p_pricing_attribs_rec.pricing_attribute50
                  ,p_pricing_attribs_rec.pricing_attribute51
                  ,p_pricing_attribs_rec.pricing_attribute52
                  ,p_pricing_attribs_rec.pricing_attribute53
                  ,p_pricing_attribs_rec.pricing_attribute54
                  ,p_pricing_attribs_rec.pricing_attribute55
                  ,p_pricing_attribs_rec.pricing_attribute56
                  ,p_pricing_attribs_rec.pricing_attribute57
                  ,p_pricing_attribs_rec.pricing_attribute58
                  ,p_pricing_attribs_rec.pricing_attribute59
                  ,p_pricing_attribs_rec.pricing_attribute60
                  ,p_pricing_attribs_rec.pricing_attribute61
                  ,p_pricing_attribs_rec.pricing_attribute62
                  ,p_pricing_attribs_rec.pricing_attribute63
                  ,p_pricing_attribs_rec.pricing_attribute64
                  ,p_pricing_attribs_rec.pricing_attribute65
                  ,p_pricing_attribs_rec.pricing_attribute66
                  ,p_pricing_attribs_rec.pricing_attribute67
                  ,p_pricing_attribs_rec.pricing_attribute68
                  ,p_pricing_attribs_rec.pricing_attribute69
                  ,p_pricing_attribs_rec.pricing_attribute70
                  ,p_pricing_attribs_rec.pricing_attribute71
                  ,p_pricing_attribs_rec.pricing_attribute72
                  ,p_pricing_attribs_rec.pricing_attribute73
                  ,p_pricing_attribs_rec.pricing_attribute74
                  ,p_pricing_attribs_rec.pricing_attribute75
                  ,p_pricing_attribs_rec.pricing_attribute76
                  ,p_pricing_attribs_rec.pricing_attribute77
                  ,p_pricing_attribs_rec.pricing_attribute78
                  ,p_pricing_attribs_rec.pricing_attribute79
                  ,p_pricing_attribs_rec.pricing_attribute80
                  ,p_pricing_attribs_rec.pricing_attribute81
                  ,p_pricing_attribs_rec.pricing_attribute82
                  ,p_pricing_attribs_rec.pricing_attribute83
                  ,p_pricing_attribs_rec.pricing_attribute84
                  ,p_pricing_attribs_rec.pricing_attribute85
                  ,p_pricing_attribs_rec.pricing_attribute86
                  ,p_pricing_attribs_rec.pricing_attribute87
                  ,p_pricing_attribs_rec.pricing_attribute88
                  ,p_pricing_attribs_rec.pricing_attribute89
                  ,p_pricing_attribs_rec.pricing_attribute90
                  ,p_pricing_attribs_rec.pricing_attribute91
                  ,p_pricing_attribs_rec.pricing_attribute92
                  ,p_pricing_attribs_rec.pricing_attribute93
                  ,p_pricing_attribs_rec.pricing_attribute94
                  ,p_pricing_attribs_rec.pricing_attribute95
                  ,p_pricing_attribs_rec.pricing_attribute96
                  ,p_pricing_attribs_rec.pricing_attribute97
                  ,p_pricing_attribs_rec.pricing_attribute98
                  ,p_pricing_attribs_rec.pricing_attribute99
                  ,p_pricing_attribs_rec.pricing_attribute100
                  );

        -- IF CSI_Instance_parties_vld_pvt.Is_Instance_creation_complete( p_ext_attrib_rec.INSTANCE_ID ) THEN
        -- Call create_transaction to create txn log

        CSI_TRANSACTIONS_PVT.Create_transaction
          (  p_api_version            => p_api_version
            ,p_commit                 => fnd_api.g_false
            ,p_init_msg_list          => p_init_msg_list
            ,p_validation_level       => p_validation_level
            ,p_Success_If_Exists_Flag => 'Y'
            ,p_transaction_rec        => p_txn_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
          );

         IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            FND_MESSAGE.SET_NAME('CSI','CSI_FAILED_TO_VALIDATE_TXN');
            FND_MESSAGE.SET_TOKEN('TRANSACTION_ID',p_txn_rec.transaction_id );
            FND_MSG_PUB.Add;
            ROLLBACK TO create_pricing_attribs;
            RETURN;
         END IF;


        -- Get a unique org_assignment number from the sequence
        l_pricing_attrib_h_id := csi_pricing_attrib_vld_pvt.get_pricing_attrib_h_id;

        -- Create a history
        CSI_I_PRICING_ATTRIBS_H_PKG.Insert_Row(
          px_PRICE_ATTRIB_HISTORY_ID            => l_pricing_attrib_h_id,
          p_PRICING_ATTRIBUTE_ID                => l_pricing_attrib_id,
          p_TRANSACTION_ID                      => p_txn_rec.transaction_id,
          p_OLD_PRICING_CONTEXT                 => NULL,
          p_NEW_PRICING_CONTEXT                 => p_pricing_attribs_rec.pricing_context,
          p_OLD_PRICING_ATTRIBUTE1              => NULL,
          p_NEW_PRICING_ATTRIBUTE1              => p_pricing_attribs_rec.pricing_attribute1,
          p_OLD_PRICING_ATTRIBUTE2              => NULL,
          p_NEW_PRICING_ATTRIBUTE2              => p_pricing_attribs_rec.pricing_attribute2,
          p_OLD_PRICING_ATTRIBUTE3              => NULL,
          p_NEW_PRICING_ATTRIBUTE3              => p_pricing_attribs_rec.pricing_attribute3,
          p_OLD_PRICING_ATTRIBUTE4              => NULL,
          p_NEW_PRICING_ATTRIBUTE4              => p_pricing_attribs_rec.pricing_attribute4,
          p_OLD_PRICING_ATTRIBUTE5              => NULL,
          p_NEW_PRICING_ATTRIBUTE5              => p_pricing_attribs_rec.pricing_attribute5,
          p_OLD_PRICING_ATTRIBUTE6              => NULL,
          p_NEW_PRICING_ATTRIBUTE6              => p_pricing_attribs_rec.pricing_attribute6,
          p_OLD_PRICING_ATTRIBUTE7              => NULL,
          p_NEW_PRICING_ATTRIBUTE7              => p_pricing_attribs_rec.pricing_attribute7,
          p_OLD_PRICING_ATTRIBUTE8              => NULL,
          p_NEW_PRICING_ATTRIBUTE8              => p_pricing_attribs_rec.pricing_attribute8,
          p_OLD_PRICING_ATTRIBUTE9              => NULL,
          p_NEW_PRICING_ATTRIBUTE9              => p_pricing_attribs_rec.pricing_attribute9,
          p_OLD_PRICING_ATTRIBUTE10             => NULL,
          p_NEW_PRICING_ATTRIBUTE10             => p_pricing_attribs_rec.pricing_attribute10,
          p_OLD_PRICING_ATTRIBUTE11             => NULL,
          p_NEW_PRICING_ATTRIBUTE11             => p_pricing_attribs_rec.pricing_attribute11,
          p_OLD_PRICING_ATTRIBUTE12             => NULL,
          p_NEW_PRICING_ATTRIBUTE12             => p_pricing_attribs_rec.pricing_attribute12,
          p_OLD_PRICING_ATTRIBUTE13             => NULL,
          p_NEW_PRICING_ATTRIBUTE13             => p_pricing_attribs_rec.pricing_attribute13,
          p_OLD_PRICING_ATTRIBUTE14             => NULL,
          p_NEW_PRICING_ATTRIBUTE14             => p_pricing_attribs_rec.pricing_attribute14,
          p_OLD_PRICING_ATTRIBUTE15             => NULL,
          p_NEW_PRICING_ATTRIBUTE15             => p_pricing_attribs_rec.pricing_attribute15,
          p_OLD_PRICING_ATTRIBUTE16             => NULL,
          p_NEW_PRICING_ATTRIBUTE16             => p_pricing_attribs_rec.pricing_attribute16,
          p_OLD_PRICING_ATTRIBUTE17             => NULL,
          p_NEW_PRICING_ATTRIBUTE17             => p_pricing_attribs_rec.pricing_attribute17,
          p_OLD_PRICING_ATTRIBUTE18             => NULL,
          p_NEW_PRICING_ATTRIBUTE18             => p_pricing_attribs_rec.pricing_attribute18,
          p_OLD_PRICING_ATTRIBUTE19             => NULL,
          p_NEW_PRICING_ATTRIBUTE19             => p_pricing_attribs_rec.pricing_attribute19,
          p_OLD_PRICING_ATTRIBUTE20             => NULL,
          p_NEW_PRICING_ATTRIBUTE20             => p_pricing_attribs_rec.pricing_attribute20,
          p_OLD_PRICING_ATTRIBUTE21             => NULL,
          p_NEW_PRICING_ATTRIBUTE21             => p_pricing_attribs_rec.pricing_attribute21,
          p_OLD_PRICING_ATTRIBUTE22             => NULL,
          p_NEW_PRICING_ATTRIBUTE22             => p_pricing_attribs_rec.pricing_attribute22,
          p_OLD_PRICING_ATTRIBUTE23             => NULL,
          p_NEW_PRICING_ATTRIBUTE23             => p_pricing_attribs_rec.pricing_attribute23,
          p_OLD_PRICING_ATTRIBUTE24             => NULL,
          p_NEW_PRICING_ATTRIBUTE24             => p_pricing_attribs_rec.pricing_attribute24,
          p_NEW_PRICING_ATTRIBUTE25             => NULL,
          p_OLD_PRICING_ATTRIBUTE25             => p_pricing_attribs_rec.pricing_attribute25,
          p_OLD_PRICING_ATTRIBUTE26             => NULL,
          p_NEW_PRICING_ATTRIBUTE26             => p_pricing_attribs_rec.pricing_attribute26,
          p_OLD_PRICING_ATTRIBUTE27             => NULL,
          p_NEW_PRICING_ATTRIBUTE27             => p_pricing_attribs_rec.pricing_attribute27,
          p_OLD_PRICING_ATTRIBUTE28             => NULL,
          p_NEW_PRICING_ATTRIBUTE28             => p_pricing_attribs_rec.pricing_attribute28,
          p_OLD_PRICING_ATTRIBUTE29             => NULL,
          p_NEW_PRICING_ATTRIBUTE29             => p_pricing_attribs_rec.pricing_attribute29,
          p_OLD_PRICING_ATTRIBUTE30             => NULL,
          p_NEW_PRICING_ATTRIBUTE30             => p_pricing_attribs_rec.pricing_attribute30,
          p_OLD_PRICING_ATTRIBUTE31             => NULL,
          p_NEW_PRICING_ATTRIBUTE31             => p_pricing_attribs_rec.pricing_attribute31,
          p_OLD_PRICING_ATTRIBUTE32             => NULL,
          p_NEW_PRICING_ATTRIBUTE32             => p_pricing_attribs_rec.pricing_attribute32,
          p_OLD_PRICING_ATTRIBUTE33             => NULL,
          p_NEW_PRICING_ATTRIBUTE33             => p_pricing_attribs_rec.pricing_attribute33,
          p_OLD_PRICING_ATTRIBUTE34             => NULL,
          p_NEW_PRICING_ATTRIBUTE34             => p_pricing_attribs_rec.pricing_attribute34,
          p_OLD_PRICING_ATTRIBUTE35             => NULL,
          p_NEW_PRICING_ATTRIBUTE35             => p_pricing_attribs_rec.pricing_attribute35,
          p_OLD_PRICING_ATTRIBUTE36             => NULL,
          p_NEW_PRICING_ATTRIBUTE36             => p_pricing_attribs_rec.pricing_attribute36,
          p_OLD_PRICING_ATTRIBUTE37             => NULL,
          p_NEW_PRICING_ATTRIBUTE37             => p_pricing_attribs_rec.pricing_attribute37,
          p_OLD_PRICING_ATTRIBUTE38             => NULL,
          p_NEW_PRICING_ATTRIBUTE38             => p_pricing_attribs_rec.pricing_attribute38,
          p_OLD_PRICING_ATTRIBUTE39             => NULL,
          p_NEW_PRICING_ATTRIBUTE39             => p_pricing_attribs_rec.pricing_attribute39,
          p_OLD_PRICING_ATTRIBUTE40             => NULL,
          p_NEW_PRICING_ATTRIBUTE40             => p_pricing_attribs_rec.pricing_attribute40,
          p_OLD_PRICING_ATTRIBUTE41             => NULL,
          p_NEW_PRICING_ATTRIBUTE41             => p_pricing_attribs_rec.pricing_attribute41,
          p_OLD_PRICING_ATTRIBUTE42             => NULL,
          p_NEW_PRICING_ATTRIBUTE42             => p_pricing_attribs_rec.pricing_attribute42,
          p_OLD_PRICING_ATTRIBUTE43             => NULL,
          p_NEW_PRICING_ATTRIBUTE43             => p_pricing_attribs_rec.pricing_attribute43,
          p_OLD_PRICING_ATTRIBUTE44             => NULL,
          p_NEW_PRICING_ATTRIBUTE44             => p_pricing_attribs_rec.pricing_attribute44,
          p_OLD_PRICING_ATTRIBUTE45             => NULL,
          p_NEW_PRICING_ATTRIBUTE45             => p_pricing_attribs_rec.pricing_attribute45,
          p_OLD_PRICING_ATTRIBUTE46             => NULL,
          p_NEW_PRICING_ATTRIBUTE46             => p_pricing_attribs_rec.pricing_attribute46,
          p_OLD_PRICING_ATTRIBUTE47             => NULL,
          p_NEW_PRICING_ATTRIBUTE47             => p_pricing_attribs_rec.pricing_attribute47,
          p_OLD_PRICING_ATTRIBUTE48             => NULL,
          p_NEW_PRICING_ATTRIBUTE48             => p_pricing_attribs_rec.pricing_attribute48,
          p_OLD_PRICING_ATTRIBUTE49             => NULL,
          p_NEW_PRICING_ATTRIBUTE49             => p_pricing_attribs_rec.pricing_attribute49,
          p_OLD_PRICING_ATTRIBUTE50             => NULL,
          p_NEW_PRICING_ATTRIBUTE50             => p_pricing_attribs_rec.pricing_attribute50,
          p_OLD_PRICING_ATTRIBUTE51             => NULL,
          p_NEW_PRICING_ATTRIBUTE51             => p_pricing_attribs_rec.pricing_attribute51,
          p_OLD_PRICING_ATTRIBUTE52             => NULL,
          p_NEW_PRICING_ATTRIBUTE52             => p_pricing_attribs_rec.pricing_attribute52,
          p_OLD_PRICING_ATTRIBUTE53             => NULL,
          p_NEW_PRICING_ATTRIBUTE53             => p_pricing_attribs_rec.pricing_attribute53,
          p_OLD_PRICING_ATTRIBUTE54             => NULL,
          p_NEW_PRICING_ATTRIBUTE54             => p_pricing_attribs_rec.pricing_attribute54,
          p_OLD_PRICING_ATTRIBUTE55             => NULL,
          p_NEW_PRICING_ATTRIBUTE55             => p_pricing_attribs_rec.pricing_attribute55,
          p_OLD_PRICING_ATTRIBUTE56             => NULL,
          p_NEW_PRICING_ATTRIBUTE56             => p_pricing_attribs_rec.pricing_attribute56,
          p_OLD_PRICING_ATTRIBUTE57             => NULL,
          p_NEW_PRICING_ATTRIBUTE57             => p_pricing_attribs_rec.pricing_attribute57,
          p_OLD_PRICING_ATTRIBUTE58             => NULL,
          p_NEW_PRICING_ATTRIBUTE58             => p_pricing_attribs_rec.pricing_attribute58,
          p_OLD_PRICING_ATTRIBUTE59             => NULL,
          p_NEW_PRICING_ATTRIBUTE59             => p_pricing_attribs_rec.pricing_attribute59,
          p_OLD_PRICING_ATTRIBUTE60             => NULL,
          p_NEW_PRICING_ATTRIBUTE60             => p_pricing_attribs_rec.pricing_attribute60,
          p_OLD_PRICING_ATTRIBUTE61             => NULL,
          p_NEW_PRICING_ATTRIBUTE61             => p_pricing_attribs_rec.pricing_attribute61,
          p_OLD_PRICING_ATTRIBUTE62             => NULL,
          p_NEW_PRICING_ATTRIBUTE62             => p_pricing_attribs_rec.pricing_attribute62,
          p_OLD_PRICING_ATTRIBUTE63             => NULL,
          p_NEW_PRICING_ATTRIBUTE63             => p_pricing_attribs_rec.pricing_attribute63,
          p_OLD_PRICING_ATTRIBUTE64             => NULL,
          p_NEW_PRICING_ATTRIBUTE64             => p_pricing_attribs_rec.pricing_attribute64,
          p_OLD_PRICING_ATTRIBUTE65             => NULL,
          p_NEW_PRICING_ATTRIBUTE65             => p_pricing_attribs_rec.pricing_attribute65,
          p_OLD_PRICING_ATTRIBUTE66             => NULL,
          p_NEW_PRICING_ATTRIBUTE66             => p_pricing_attribs_rec.pricing_attribute66,
          p_OLD_PRICING_ATTRIBUTE67             => NULL,
          p_NEW_PRICING_ATTRIBUTE67             => p_pricing_attribs_rec.pricing_attribute67,
          p_OLD_PRICING_ATTRIBUTE68             => NULL,
          p_NEW_PRICING_ATTRIBUTE68             => p_pricing_attribs_rec.pricing_attribute68,
          p_OLD_PRICING_ATTRIBUTE69             => NULL,
          p_NEW_PRICING_ATTRIBUTE69             => p_pricing_attribs_rec.pricing_attribute69,
          p_OLD_PRICING_ATTRIBUTE70             => NULL,
          p_NEW_PRICING_ATTRIBUTE70             => p_pricing_attribs_rec.pricing_attribute70,
          p_OLD_PRICING_ATTRIBUTE71             => NULL,
          p_NEW_PRICING_ATTRIBUTE71             => p_pricing_attribs_rec.pricing_attribute71,
          p_OLD_PRICING_ATTRIBUTE72             => NULL,
          p_NEW_PRICING_ATTRIBUTE72             => p_pricing_attribs_rec.pricing_attribute72,
          p_OLD_PRICING_ATTRIBUTE73             => NULL,
          p_NEW_PRICING_ATTRIBUTE73             => p_pricing_attribs_rec.pricing_attribute73,
          p_OLD_PRICING_ATTRIBUTE74             => NULL,
          p_NEW_PRICING_ATTRIBUTE74             => p_pricing_attribs_rec.pricing_attribute74,
          p_OLD_PRICING_ATTRIBUTE75             => NULL,
          p_NEW_PRICING_ATTRIBUTE75             => p_pricing_attribs_rec.pricing_attribute75,
          p_OLD_PRICING_ATTRIBUTE76             => NULL,
          p_NEW_PRICING_ATTRIBUTE76             => p_pricing_attribs_rec.pricing_attribute76,
          p_OLD_PRICING_ATTRIBUTE77             => NULL,
          p_NEW_PRICING_ATTRIBUTE77             => p_pricing_attribs_rec.pricing_attribute77,
          p_OLD_PRICING_ATTRIBUTE78             => NULL,
          p_NEW_PRICING_ATTRIBUTE78             => p_pricing_attribs_rec.pricing_attribute78,
          p_OLD_PRICING_ATTRIBUTE79             => NULL,
          p_NEW_PRICING_ATTRIBUTE79             => p_pricing_attribs_rec.pricing_attribute79,
          p_OLD_PRICING_ATTRIBUTE80             => NULL,
          p_NEW_PRICING_ATTRIBUTE80             => p_pricing_attribs_rec.pricing_attribute80,
          p_OLD_PRICING_ATTRIBUTE81             => NULL,
          p_NEW_PRICING_ATTRIBUTE81             => p_pricing_attribs_rec.pricing_attribute81,
          p_OLD_PRICING_ATTRIBUTE82             => NULL,
          p_NEW_PRICING_ATTRIBUTE82             => p_pricing_attribs_rec.pricing_attribute82,
          p_OLD_PRICING_ATTRIBUTE83             => NULL,
          p_NEW_PRICING_ATTRIBUTE83             => p_pricing_attribs_rec.pricing_attribute83,
          p_OLD_PRICING_ATTRIBUTE84             => NULL,
          p_NEW_PRICING_ATTRIBUTE84             => p_pricing_attribs_rec.pricing_attribute84,
          p_OLD_PRICING_ATTRIBUTE85             => NULL,
          p_NEW_PRICING_ATTRIBUTE85             => p_pricing_attribs_rec.pricing_attribute85,
          p_OLD_PRICING_ATTRIBUTE86             => NULL,
          p_NEW_PRICING_ATTRIBUTE86             => p_pricing_attribs_rec.pricing_attribute86,
          p_OLD_PRICING_ATTRIBUTE87             => NULL,
          p_NEW_PRICING_ATTRIBUTE87             => p_pricing_attribs_rec.pricing_attribute87,
          p_OLD_PRICING_ATTRIBUTE88             => NULL,
          p_NEW_PRICING_ATTRIBUTE88             => p_pricing_attribs_rec.pricing_attribute88,
          p_OLD_PRICING_ATTRIBUTE89             => NULL,
          p_NEW_PRICING_ATTRIBUTE89             => p_pricing_attribs_rec.pricing_attribute89,
          p_OLD_PRICING_ATTRIBUTE90             => NULL,
          p_NEW_PRICING_ATTRIBUTE90             => p_pricing_attribs_rec.pricing_attribute90,
          p_OLD_PRICING_ATTRIBUTE91             => NULL,
          p_NEW_PRICING_ATTRIBUTE91             => p_pricing_attribs_rec.pricing_attribute91,
          p_OLD_PRICING_ATTRIBUTE92             => NULL,
          p_NEW_PRICING_ATTRIBUTE92             => p_pricing_attribs_rec.pricing_attribute92,
          p_OLD_PRICING_ATTRIBUTE93             => NULL,
          p_NEW_PRICING_ATTRIBUTE93             => p_pricing_attribs_rec.pricing_attribute93,
          p_OLD_PRICING_ATTRIBUTE94             => NULL,
          p_NEW_PRICING_ATTRIBUTE94             => p_pricing_attribs_rec.pricing_attribute94,
          p_OLD_PRICING_ATTRIBUTE95             => NULL,
          p_NEW_PRICING_ATTRIBUTE95             => p_pricing_attribs_rec.pricing_attribute95,
          p_OLD_PRICING_ATTRIBUTE96             => NULL,
          p_NEW_PRICING_ATTRIBUTE96             => p_pricing_attribs_rec.pricing_attribute96,
          p_OLD_PRICING_ATTRIBUTE97             => NULL,
          p_NEW_PRICING_ATTRIBUTE97             => p_pricing_attribs_rec.pricing_attribute97,
          p_OLD_PRICING_ATTRIBUTE98             => NULL,
          p_NEW_PRICING_ATTRIBUTE98             => p_pricing_attribs_rec.pricing_attribute98,
          p_OLD_PRICING_ATTRIBUTE99             => NULL,
          p_NEW_PRICING_ATTRIBUTE99             => p_pricing_attribs_rec.pricing_attribute99,
          p_OLD_PRICING_ATTRIBUTE100            => NULL,
          p_NEW_PRICING_ATTRIBUTE100            => p_pricing_attribs_rec.pricing_attribute100,
          p_OLD_ACTIVE_START_DATE               => NULL,
          p_NEW_ACTIVE_START_DATE               =>  p_pricing_attribs_rec.active_start_date,
          p_OLD_ACTIVE_END_DATE                 => NULL,
          p_NEW_ACTIVE_END_DATE                 =>  p_pricing_attribs_rec.active_end_date,
          p_OLD_CONTEXT                         => NULL                      ,
          p_NEW_CONTEXT                         => p_pricing_attribs_rec.context       ,
          p_OLD_ATTRIBUTE1                      => NULL                      ,
          p_NEW_ATTRIBUTE1                      => p_pricing_attribs_rec.ATTRIBUTE1    ,
          p_OLD_ATTRIBUTE2                      => NULL                      ,
          p_NEW_ATTRIBUTE2                      => p_pricing_attribs_rec.ATTRIBUTE2    ,
          p_OLD_ATTRIBUTE3                      => NULL                      ,
          p_NEW_ATTRIBUTE3                      => p_pricing_attribs_rec.ATTRIBUTE3    ,
          p_OLD_ATTRIBUTE4                      => NULL                      ,
          p_NEW_ATTRIBUTE4                      => p_pricing_attribs_rec.ATTRIBUTE4    ,
          p_OLD_ATTRIBUTE5                      => NULL                      ,
          p_NEW_ATTRIBUTE5                      => p_pricing_attribs_rec.ATTRIBUTE5    ,
          p_OLD_ATTRIBUTE6                      => NULL                      ,
          p_NEW_ATTRIBUTE6                      => p_pricing_attribs_rec.ATTRIBUTE6    ,
          p_OLD_ATTRIBUTE7                      => NULL                      ,
          p_NEW_ATTRIBUTE7                      => p_pricing_attribs_rec.ATTRIBUTE7    ,
          p_OLD_ATTRIBUTE8                      => NULL                      ,
          p_NEW_ATTRIBUTE8                      => p_pricing_attribs_rec.ATTRIBUTE8    ,
          p_OLD_ATTRIBUTE9                      => NULL                      ,
          p_NEW_ATTRIBUTE9                      => p_pricing_attribs_rec.ATTRIBUTE9    ,
          p_OLD_ATTRIBUTE10                     => NULL                      ,
          p_NEW_ATTRIBUTE10                     => p_pricing_attribs_rec.ATTRIBUTE10   ,
          p_OLD_ATTRIBUTE11                     => NULL                      ,
          p_NEW_ATTRIBUTE11                     => p_pricing_attribs_rec.ATTRIBUTE11   ,
          p_OLD_ATTRIBUTE12                     => NULL                      ,
          p_NEW_ATTRIBUTE12                     => p_pricing_attribs_rec.ATTRIBUTE12   ,
          p_OLD_ATTRIBUTE13                     => NULL                      ,
          p_NEW_ATTRIBUTE13                     => p_pricing_attribs_rec.ATTRIBUTE13   ,
          p_OLD_ATTRIBUTE14                     => NULL                      ,
          p_NEW_ATTRIBUTE14                     => p_pricing_attribs_rec.ATTRIBUTE14   ,
          p_OLD_ATTRIBUTE15                     => NULL                      ,
          p_NEW_ATTRIBUTE15                     => p_pricing_attribs_rec.ATTRIBUTE15   ,
          p_FULL_DUMP_FLAG                      => 'N',
          p_CREATED_BY                          => fnd_global.user_id,
          p_CREATION_DATE                       => sysdate,
          p_LAST_UPDATED_BY                     => fnd_global.user_id,
          p_LAST_UPDATE_DATE                    => sysdate,
          p_LAST_UPDATE_LOGIN                   => fnd_global.user_id,
          p_OBJECT_VERSION_NUMBER               => 1);


     --      END IF;
     END IF; -- called from grp check


      -- End of API body

      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is  get message info.
      FND_MSG_PUB.Count_And_Get
           (p_count      =>       x_msg_count ,
            p_data       =>       x_msg_data
            );

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO create_pricing_attribs;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (  p_count   =>      x_msg_count,
                   p_data    =>      x_msg_data
                );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            ROLLBACK TO create_pricing_attribs;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (   p_count  =>      x_msg_count,
                    p_data   =>      x_msg_data
                );

      WHEN OTHERS THEN
            ROLLBACK TO  create_pricing_attribs;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                    FND_MSG_PUB.Add_Exc_Msg
                        ( g_pkg_name,
                          l_api_name
                         );
            END IF;

            FND_MSG_PUB.Count_And_Get
                   (p_count  =>      x_msg_count,
                    p_data   =>      x_msg_data
                    );

END create_pricing_attribs;



/*--------------------------------------------------*/
/* procedure name: update_pricing_attribs           */
/* description :  Updates the existing pricing      */
/*                attributes for an item instance   */
/*                                                  */
/*--------------------------------------------------*/

PROCEDURE update_pricing_attribs
 (    p_api_version                 IN      NUMBER
     ,p_commit                      IN      VARCHAR2
     ,p_init_msg_list               IN      VARCHAR2
     ,p_validation_level            IN      NUMBER
     ,p_pricing_attribs_rec         IN      csi_datastructures_pub.pricing_attribs_rec
     ,p_txn_rec                     IN  OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status                   OUT NOCOPY VARCHAR2
     ,x_msg_count                       OUT NOCOPY NUMBER
     ,x_msg_data                        OUT NOCOPY VARCHAR2
 )
IS
    l_api_name                   CONSTANT VARCHAR2(30)      := 'update_pricing_attribs';
    l_api_version                CONSTANT NUMBER            := 1.0;
    l_debug_level                         NUMBER;
    l_msg_index                           NUMBER;
    l_msg_count                           NUMBER;
    l_pricing_attrib_id                   NUMBER            := p_pricing_attribs_rec.pricing_attribute_id;
    l_pricing_attrib_h_id                 NUMBER;
    l_pricing_attribs_rec                 csi_datastructures_pub.pricing_attribs_rec;
    l_temp_pricing_attribs_rec            csi_datastructures_pub.pricing_attribs_rec;
    l_dump_frequency                      NUMBER;
    l_dump_frequency_flag                 VARCHAR2(30);
    l_pricing_history_rec                 csi_datastructures_pub.pricing_history_rec;

CURSOR pricing_hist_csr (p_pricing_hist_id NUMBER) IS
    SELECT  *
    FROM    csi_i_pricing_attribs_h
    WHERE   csi_i_pricing_attribs_h.price_attrib_history_id = p_pricing_hist_id
    FOR UPDATE OF object_version_number;
l_pricing_hist_id      NUMBER;
l_pricing_hist_csr     pricing_hist_csr%ROWTYPE;
BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT      update_pricing_attribs;

          -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name ,
                                        g_pkg_name)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Check the profile option debug_level for debug message reporting
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'update_pricing_attribs');
    END IF;


    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
          csi_gen_utility_pvt.put_line(
                                     p_api_version      ||'-'
                                  || p_commit           ||'-'
                                  || p_init_msg_list    ||'-'
                                  || p_validation_level   );
     -- Dump pricing_attribs_rec
          csi_gen_utility_pvt.dump_pricing_attribs_rec(p_pricing_attribs_rec);
     -- Dump txn_rec
          csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
    END IF;


    -- Start API body

    -- Validate pricing_attribute_id
    IF NOT(csi_pricing_attrib_vld_pvt.Val_and_get_pri_att_id
             (p_pricing_attribs_rec.pricing_attribute_id,
              l_pricing_attribs_rec)) THEN

       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate object_version_number
    IF NOT(csi_pricing_attrib_vld_pvt.Is_valid_obj_ver_num
            (p_pricing_attribs_rec.object_version_number
          ,l_pricing_attribs_rec.object_version_number
          )) THEN

      RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Validate if the instance is updatable
    IF NOT(csi_pricing_attrib_vld_pvt.Is_Updatable
             (l_pricing_attribs_rec.active_end_date ,
            p_pricing_attribs_rec.active_end_date )) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate instance id for which the update is related to
    IF NOT(csi_pricing_attrib_vld_pvt.Is_Valid_instance_id
            (l_pricing_attribs_rec.instance_id,
           'UPDATE'
          )) THEN

        -- Check if it is an expire operation
           IF NOT(csi_pricing_attrib_vld_pvt.Is_Expire_Op
                     (p_pricing_attribs_rec)) THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
    END IF;


    -- Validate instance id
    IF ( p_pricing_attribs_rec.instance_id <> FND_API.G_MISS_NUM ) THEN
       IF NOT(csi_pricing_attrib_vld_pvt.Val_inst_id_for_update
            ( p_pricing_attribs_rec.instance_id
             ,l_pricing_attribs_rec.instance_id
             )) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;


    -- Verify start effective date
    IF ( p_pricing_attribs_rec.active_start_date <> FND_API.G_MISS_DATE) THEN
       IF (p_pricing_attribs_rec.active_start_date <> l_pricing_attribs_rec.active_start_date) THEN
               FND_MESSAGE.Set_Name('CSI', 'CSI_API_UPD_NOT_ALLOWED');
               FND_MESSAGE.Set_Token('COLUMN', 'PRICING ATTRIBUTE START_DATE');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    -- Verify end effective date
    IF ( p_pricing_attribs_rec.active_end_date <> FND_API.G_MISS_DATE) THEN
       IF p_pricing_attribs_rec.active_end_date is NOT NULL THEN
         IF g_expire_pric_flag <> 'Y' THEN
            IF NOT(csi_pricing_attrib_vld_pvt.Is_EndDate_Valid
               (p_pricing_attribs_rec.ACTIVE_START_DATE,
                p_pricing_attribs_rec.ACTIVE_END_DATE,
                p_pricing_attribs_rec.INSTANCE_ID ,
      		    p_pricing_attribs_rec.PRICING_ATTRIBUTE_ID ,
	            p_txn_rec.TRANSACTION_ID))  THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
       END IF;
    END IF;


    -- Get the new object version number
    l_pricing_attribs_rec.object_version_number :=
      csi_pricing_attrib_vld_pvt.get_object_version_number(l_pricing_attribs_rec.object_version_number);

    CSI_I_PRICING_ATTRIBS_PKG.Update_Row
                  (
                  l_pricing_attrib_id
                  ,p_pricing_attribs_rec.instance_id
                  ,p_pricing_attribs_rec.active_start_date
                  ,p_pricing_attribs_rec.active_end_date
                  ,p_pricing_attribs_rec.context
                  ,p_pricing_attribs_rec.attribute1
                  ,p_pricing_attribs_rec.attribute2
                  ,p_pricing_attribs_rec.attribute3
                  ,p_pricing_attribs_rec.attribute4
                  ,p_pricing_attribs_rec.attribute5
                  ,p_pricing_attribs_rec.attribute6
                  ,p_pricing_attribs_rec.attribute7
                  ,p_pricing_attribs_rec.attribute8
                  ,p_pricing_attribs_rec.attribute9
                  ,p_pricing_attribs_rec.attribute10
                  ,p_pricing_attribs_rec.attribute11
                  ,p_pricing_attribs_rec.attribute12
                  ,p_pricing_attribs_rec.attribute13
                  ,p_pricing_attribs_rec.attribute14
                  ,p_pricing_attribs_rec.attribute15
                  ,fnd_api.g_miss_num -- fnd_global.user_id
                  ,fnd_api.g_miss_date
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,l_pricing_attribs_rec.object_version_number
                  ,p_pricing_attribs_rec.pricing_context
                  ,p_pricing_attribs_rec.pricing_attribute1
                  ,p_pricing_attribs_rec.pricing_attribute2
                  ,p_pricing_attribs_rec.pricing_attribute3
                  ,p_pricing_attribs_rec.pricing_attribute4
                  ,p_pricing_attribs_rec.pricing_attribute5
                  ,p_pricing_attribs_rec.pricing_attribute6
                  ,p_pricing_attribs_rec.pricing_attribute7
                  ,p_pricing_attribs_rec.pricing_attribute8
                  ,p_pricing_attribs_rec.pricing_attribute9
                  ,p_pricing_attribs_rec.pricing_attribute10
                  ,p_pricing_attribs_rec.pricing_attribute11
                  ,p_pricing_attribs_rec.pricing_attribute12
                  ,p_pricing_attribs_rec.pricing_attribute13
                  ,p_pricing_attribs_rec.pricing_attribute14
                  ,p_pricing_attribs_rec.pricing_attribute15
                  ,p_pricing_attribs_rec.pricing_attribute16
                  ,p_pricing_attribs_rec.pricing_attribute17
                  ,p_pricing_attribs_rec.pricing_attribute18
                  ,p_pricing_attribs_rec.pricing_attribute19
                  ,p_pricing_attribs_rec.pricing_attribute20
                  ,p_pricing_attribs_rec.pricing_attribute21
                  ,p_pricing_attribs_rec.pricing_attribute22
                  ,p_pricing_attribs_rec.pricing_attribute23
                  ,p_pricing_attribs_rec.pricing_attribute24
                  ,p_pricing_attribs_rec.pricing_attribute25
                  ,p_pricing_attribs_rec.pricing_attribute26
                  ,p_pricing_attribs_rec.pricing_attribute27
                  ,p_pricing_attribs_rec.pricing_attribute28
                  ,p_pricing_attribs_rec.pricing_attribute29
                  ,p_pricing_attribs_rec.pricing_attribute30
                  ,p_pricing_attribs_rec.pricing_attribute31
                  ,p_pricing_attribs_rec.pricing_attribute32
                  ,p_pricing_attribs_rec.pricing_attribute33
                  ,p_pricing_attribs_rec.pricing_attribute34
                  ,p_pricing_attribs_rec.pricing_attribute35
                  ,p_pricing_attribs_rec.pricing_attribute36
                  ,p_pricing_attribs_rec.pricing_attribute37
                  ,p_pricing_attribs_rec.pricing_attribute38
                  ,p_pricing_attribs_rec.pricing_attribute39
                  ,p_pricing_attribs_rec.pricing_attribute40
                  ,p_pricing_attribs_rec.pricing_attribute41
                  ,p_pricing_attribs_rec.pricing_attribute42
                  ,p_pricing_attribs_rec.pricing_attribute43
                  ,p_pricing_attribs_rec.pricing_attribute44
                  ,p_pricing_attribs_rec.pricing_attribute45
                  ,p_pricing_attribs_rec.pricing_attribute46
                  ,p_pricing_attribs_rec.pricing_attribute47
                  ,p_pricing_attribs_rec.pricing_attribute48
                  ,p_pricing_attribs_rec.pricing_attribute49
                  ,p_pricing_attribs_rec.pricing_attribute50
                  ,p_pricing_attribs_rec.pricing_attribute51
                  ,p_pricing_attribs_rec.pricing_attribute52
                  ,p_pricing_attribs_rec.pricing_attribute53
                  ,p_pricing_attribs_rec.pricing_attribute54
                  ,p_pricing_attribs_rec.pricing_attribute55
                  ,p_pricing_attribs_rec.pricing_attribute56
                  ,p_pricing_attribs_rec.pricing_attribute57
                  ,p_pricing_attribs_rec.pricing_attribute58
                  ,p_pricing_attribs_rec.pricing_attribute59
                  ,p_pricing_attribs_rec.pricing_attribute60
                  ,p_pricing_attribs_rec.pricing_attribute61
                  ,p_pricing_attribs_rec.pricing_attribute62
                  ,p_pricing_attribs_rec.pricing_attribute63
                  ,p_pricing_attribs_rec.pricing_attribute64
                  ,p_pricing_attribs_rec.pricing_attribute65
                  ,p_pricing_attribs_rec.pricing_attribute66
                  ,p_pricing_attribs_rec.pricing_attribute67
                  ,p_pricing_attribs_rec.pricing_attribute68
                  ,p_pricing_attribs_rec.pricing_attribute69
                  ,p_pricing_attribs_rec.pricing_attribute70
                  ,p_pricing_attribs_rec.pricing_attribute71
                  ,p_pricing_attribs_rec.pricing_attribute72
                  ,p_pricing_attribs_rec.pricing_attribute73
                  ,p_pricing_attribs_rec.pricing_attribute74
                  ,p_pricing_attribs_rec.pricing_attribute75
                  ,p_pricing_attribs_rec.pricing_attribute76
                  ,p_pricing_attribs_rec.pricing_attribute77
                  ,p_pricing_attribs_rec.pricing_attribute78
                  ,p_pricing_attribs_rec.pricing_attribute79
                  ,p_pricing_attribs_rec.pricing_attribute80
                  ,p_pricing_attribs_rec.pricing_attribute81
                  ,p_pricing_attribs_rec.pricing_attribute82
                  ,p_pricing_attribs_rec.pricing_attribute83
                  ,p_pricing_attribs_rec.pricing_attribute84
                  ,p_pricing_attribs_rec.pricing_attribute85
                  ,p_pricing_attribs_rec.pricing_attribute86
                  ,p_pricing_attribs_rec.pricing_attribute87
                  ,p_pricing_attribs_rec.pricing_attribute88
                  ,p_pricing_attribs_rec.pricing_attribute89
                  ,p_pricing_attribs_rec.pricing_attribute90
                  ,p_pricing_attribs_rec.pricing_attribute91
                  ,p_pricing_attribs_rec.pricing_attribute92
                  ,p_pricing_attribs_rec.pricing_attribute93
                  ,p_pricing_attribs_rec.pricing_attribute94
                  ,p_pricing_attribs_rec.pricing_attribute95
                  ,p_pricing_attribs_rec.pricing_attribute96
                  ,p_pricing_attribs_rec.pricing_attribute97
                  ,p_pricing_attribs_rec.pricing_attribute98
                  ,p_pricing_attribs_rec.pricing_attribute99
                  ,p_pricing_attribs_rec.pricing_attribute100
                  );


      -- IF CSI_Instance_parties_vld_pvt.Is_Instance_creation_complete( p_ext_attrib_rec.INSTANCE_ID ) THEN
        -- Call create_transaction to create txn log

        CSI_TRANSACTIONS_PVT.Create_transaction
          (
             p_api_version            => p_api_version
            ,p_commit                 => fnd_api.g_false
            ,p_init_msg_list          => p_init_msg_list
            ,p_validation_level       => p_validation_level
            ,p_Success_If_Exists_Flag => 'Y'
            ,p_transaction_rec        => p_txn_rec
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data
            );

           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   l_msg_index := 1;
                   l_msg_count := x_msg_count;
                   WHILE l_msg_count > 0 LOOP
                      x_msg_data := FND_MSG_PUB.GET
                      (l_msg_index,
                       FND_API.G_FALSE      );

                       csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                       l_msg_index := l_msg_index + 1;
                       l_msg_count := l_msg_count - 1;
                   END LOOP;
                   RAISE FND_API.G_EXC_ERROR;
           END IF;



        -- Get a unique pricing attribute id number from the sequence
        l_pricing_attrib_h_id := csi_pricing_attrib_vld_pvt.get_pricing_attrib_h_id;


        -- Get full dump frequency from CSI_INSTALL_PARAMETERS
       l_dump_frequency :=  csi_pricing_attrib_vld_pvt.get_full_dump_frequency;
       IF l_dump_frequency IS NULL THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- START OF MODIFICATION ON 22-JUL SK

      -- Start of modification for Bug#2547034 on 09/20/02 - rtalluri
      BEGIN

        SELECT  price_attrib_history_id
        INTO    l_pricing_hist_id
        FROM    csi_i_pricing_attribs_h h
        WHERE   h.transaction_id = p_txn_rec.transaction_id
        AND     h.pricing_attribute_id = p_pricing_attribs_rec.pricing_attribute_id;

        OPEN   pricing_hist_csr(l_pricing_hist_id);
        FETCH  pricing_hist_csr INTO l_pricing_hist_csr ;
        CLOSE  pricing_hist_csr;
     -- Grab the input record in a temporary record
        l_temp_pricing_attribs_rec := p_pricing_attribs_rec;

        IF l_pricing_hist_csr.full_dump_flag = 'Y'
        THEN

         CSI_I_PRICING_ATTRIBS_H_PKG.Update_Row(
               p_PRICE_ATTRIB_HISTORY_ID             => l_pricing_hist_id                             ,
               p_PRICING_ATTRIBUTE_ID                => fnd_api.g_miss_num                            ,
               p_TRANSACTION_ID                      => fnd_api.g_miss_num                            ,
               p_OLD_PRICING_CONTEXT                 => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_CONTEXT                 => l_temp_pricing_attribs_rec.pricing_context    ,
               p_OLD_PRICING_ATTRIBUTE1              => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE1              => l_temp_pricing_attribs_rec.pricing_attribute1 ,
               p_OLD_PRICING_ATTRIBUTE2              => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE2              => l_temp_pricing_attribs_rec.pricing_attribute2 ,
               p_OLD_PRICING_ATTRIBUTE3              => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE3              => l_temp_pricing_attribs_rec.pricing_attribute3 ,
               p_OLD_PRICING_ATTRIBUTE4              => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE4              => l_temp_pricing_attribs_rec.pricing_attribute4 ,
               p_OLD_PRICING_ATTRIBUTE5              => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE5              => l_temp_pricing_attribs_rec.pricing_attribute5 ,
               p_OLD_PRICING_ATTRIBUTE6              => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE6              => l_temp_pricing_attribs_rec.pricing_attribute6 ,
               p_OLD_PRICING_ATTRIBUTE7              => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE7              => l_temp_pricing_attribs_rec.pricing_attribute7 ,
               p_OLD_PRICING_ATTRIBUTE8              => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE8              => l_temp_pricing_attribs_rec.pricing_attribute8 ,
               p_OLD_PRICING_ATTRIBUTE9              => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE9              => l_temp_pricing_attribs_rec.pricing_attribute9 ,
               p_OLD_PRICING_ATTRIBUTE10             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE10             => l_temp_pricing_attribs_rec.pricing_attribute10,
               p_OLD_PRICING_ATTRIBUTE11             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE11             => l_temp_pricing_attribs_rec.pricing_attribute11,
               p_OLD_PRICING_ATTRIBUTE12             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE12             => l_temp_pricing_attribs_rec.pricing_attribute12,
               p_OLD_PRICING_ATTRIBUTE13             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE13             => l_temp_pricing_attribs_rec.pricing_attribute13,
               p_OLD_PRICING_ATTRIBUTE14             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE14             => l_temp_pricing_attribs_rec.pricing_attribute14,
               p_OLD_PRICING_ATTRIBUTE15             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE15             => l_temp_pricing_attribs_rec.pricing_attribute15,
               p_OLD_PRICING_ATTRIBUTE16             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE16             => l_temp_pricing_attribs_rec.pricing_attribute16,
               p_OLD_PRICING_ATTRIBUTE17             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE17             => l_temp_pricing_attribs_rec.pricing_attribute17,
               p_OLD_PRICING_ATTRIBUTE18             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE18             => l_temp_pricing_attribs_rec.pricing_attribute18,
               p_OLD_PRICING_ATTRIBUTE19             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE19             => l_temp_pricing_attribs_rec.pricing_attribute19,
               p_OLD_PRICING_ATTRIBUTE20             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE20             => l_temp_pricing_attribs_rec.pricing_attribute20,
               p_OLD_PRICING_ATTRIBUTE21             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE21             => l_temp_pricing_attribs_rec.pricing_attribute21,
               p_OLD_PRICING_ATTRIBUTE22             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE22             => l_temp_pricing_attribs_rec.pricing_attribute22,
               p_OLD_PRICING_ATTRIBUTE23             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE23             => l_temp_pricing_attribs_rec.pricing_attribute23,
               p_OLD_PRICING_ATTRIBUTE24             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE24             => l_temp_pricing_attribs_rec.pricing_attribute24,
               p_NEW_PRICING_ATTRIBUTE25             => fnd_api.g_miss_char                           ,
               p_OLD_PRICING_ATTRIBUTE25             => l_temp_pricing_attribs_rec.pricing_attribute25,
               p_OLD_PRICING_ATTRIBUTE26             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE26             => l_temp_pricing_attribs_rec.pricing_attribute26,
               p_OLD_PRICING_ATTRIBUTE27             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE27             => l_temp_pricing_attribs_rec.pricing_attribute27,
               p_OLD_PRICING_ATTRIBUTE28             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE28             => l_temp_pricing_attribs_rec.pricing_attribute28,
               p_OLD_PRICING_ATTRIBUTE29             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE29             => l_temp_pricing_attribs_rec.pricing_attribute29,
               p_OLD_PRICING_ATTRIBUTE30             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE30             => l_temp_pricing_attribs_rec.pricing_attribute30,
               p_OLD_PRICING_ATTRIBUTE31             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE31             => l_temp_pricing_attribs_rec.pricing_attribute31,
               p_OLD_PRICING_ATTRIBUTE32             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE32             => l_temp_pricing_attribs_rec.pricing_attribute32,
               p_OLD_PRICING_ATTRIBUTE33             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE33             => l_temp_pricing_attribs_rec.pricing_attribute33,
               p_OLD_PRICING_ATTRIBUTE34             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE34             => l_temp_pricing_attribs_rec.pricing_attribute34,
               p_OLD_PRICING_ATTRIBUTE35             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE35             => l_temp_pricing_attribs_rec.pricing_attribute35,
               p_OLD_PRICING_ATTRIBUTE36             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE36             => l_temp_pricing_attribs_rec.pricing_attribute36,
               p_OLD_PRICING_ATTRIBUTE37             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE37             => l_temp_pricing_attribs_rec.pricing_attribute37,
               p_OLD_PRICING_ATTRIBUTE38             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE38             => l_temp_pricing_attribs_rec.pricing_attribute38,
               p_OLD_PRICING_ATTRIBUTE39             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE39             => l_temp_pricing_attribs_rec.pricing_attribute39,
               p_OLD_PRICING_ATTRIBUTE40             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE40             => l_temp_pricing_attribs_rec.pricing_attribute40,
               p_OLD_PRICING_ATTRIBUTE41             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE41             => l_temp_pricing_attribs_rec.pricing_attribute41,
               p_OLD_PRICING_ATTRIBUTE42             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE42             => l_temp_pricing_attribs_rec.pricing_attribute42,
               p_OLD_PRICING_ATTRIBUTE43             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE43             => l_temp_pricing_attribs_rec.pricing_attribute43,
               p_OLD_PRICING_ATTRIBUTE44             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE44             => l_temp_pricing_attribs_rec.pricing_attribute44,
               p_OLD_PRICING_ATTRIBUTE45             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE45             => l_temp_pricing_attribs_rec.pricing_attribute45,
               p_OLD_PRICING_ATTRIBUTE46             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE46             => l_temp_pricing_attribs_rec.pricing_attribute46,
               p_OLD_PRICING_ATTRIBUTE47             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE47             => l_temp_pricing_attribs_rec.pricing_attribute47,
               p_OLD_PRICING_ATTRIBUTE48             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE48             => l_temp_pricing_attribs_rec.pricing_attribute48,
               p_OLD_PRICING_ATTRIBUTE49             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE49             => l_temp_pricing_attribs_rec.pricing_attribute49,
               p_OLD_PRICING_ATTRIBUTE50             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE50             => l_temp_pricing_attribs_rec.pricing_attribute50,
               p_OLD_PRICING_ATTRIBUTE51             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE51             => l_temp_pricing_attribs_rec.pricing_attribute51,
               p_OLD_PRICING_ATTRIBUTE52             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE52             => l_temp_pricing_attribs_rec.pricing_attribute52,
               p_OLD_PRICING_ATTRIBUTE53             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE53             => l_temp_pricing_attribs_rec.pricing_attribute53,
               p_OLD_PRICING_ATTRIBUTE54             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE54             => l_temp_pricing_attribs_rec.pricing_attribute54,
               p_OLD_PRICING_ATTRIBUTE55             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE55             => l_temp_pricing_attribs_rec.pricing_attribute55,
               p_OLD_PRICING_ATTRIBUTE56             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE56             => l_temp_pricing_attribs_rec.pricing_attribute56,
               p_OLD_PRICING_ATTRIBUTE57             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE57             => l_temp_pricing_attribs_rec.pricing_attribute57,
               p_OLD_PRICING_ATTRIBUTE58             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE58             => l_temp_pricing_attribs_rec.pricing_attribute58,
               p_OLD_PRICING_ATTRIBUTE59             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE59             => l_temp_pricing_attribs_rec.pricing_attribute59,
               p_OLD_PRICING_ATTRIBUTE60             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE60             => l_temp_pricing_attribs_rec.pricing_attribute60,
               p_OLD_PRICING_ATTRIBUTE61             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE61             => l_temp_pricing_attribs_rec.pricing_attribute61,
               p_OLD_PRICING_ATTRIBUTE62             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE62             => l_temp_pricing_attribs_rec.pricing_attribute62,
               p_OLD_PRICING_ATTRIBUTE63             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE63             => l_temp_pricing_attribs_rec.pricing_attribute63,
               p_OLD_PRICING_ATTRIBUTE64             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE64             => l_temp_pricing_attribs_rec.pricing_attribute64,
               p_OLD_PRICING_ATTRIBUTE65             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE65             => l_temp_pricing_attribs_rec.pricing_attribute65,
               p_OLD_PRICING_ATTRIBUTE66             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE66             => l_temp_pricing_attribs_rec.pricing_attribute66,
               p_OLD_PRICING_ATTRIBUTE67             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE67             => l_temp_pricing_attribs_rec.pricing_attribute67,
               p_OLD_PRICING_ATTRIBUTE68             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE68             => l_temp_pricing_attribs_rec.pricing_attribute68,
               p_OLD_PRICING_ATTRIBUTE69             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE69             => l_temp_pricing_attribs_rec.pricing_attribute69,
               p_OLD_PRICING_ATTRIBUTE70             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE70             => l_temp_pricing_attribs_rec.pricing_attribute70,
               p_OLD_PRICING_ATTRIBUTE71             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE71             => l_temp_pricing_attribs_rec.pricing_attribute71,
               p_OLD_PRICING_ATTRIBUTE72             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE72             => l_temp_pricing_attribs_rec.pricing_attribute72,
               p_OLD_PRICING_ATTRIBUTE73             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE73             => l_temp_pricing_attribs_rec.pricing_attribute73,
               p_OLD_PRICING_ATTRIBUTE74             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE74             => l_temp_pricing_attribs_rec.pricing_attribute74,
               p_OLD_PRICING_ATTRIBUTE75             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE75             => l_temp_pricing_attribs_rec.pricing_attribute75,
               p_OLD_PRICING_ATTRIBUTE76             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE76             => l_temp_pricing_attribs_rec.pricing_attribute76,
               p_OLD_PRICING_ATTRIBUTE77             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE77             => l_temp_pricing_attribs_rec.pricing_attribute77,
               p_OLD_PRICING_ATTRIBUTE78             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE78             => l_temp_pricing_attribs_rec.pricing_attribute78,
               p_OLD_PRICING_ATTRIBUTE79             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE79             => l_temp_pricing_attribs_rec.pricing_attribute79,
               p_OLD_PRICING_ATTRIBUTE80             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE80             => l_temp_pricing_attribs_rec.pricing_attribute80,
               p_OLD_PRICING_ATTRIBUTE81             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE81             => l_temp_pricing_attribs_rec.pricing_attribute81,
               p_OLD_PRICING_ATTRIBUTE82             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE82             => l_temp_pricing_attribs_rec.pricing_attribute82,
               p_OLD_PRICING_ATTRIBUTE83             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE83             => l_temp_pricing_attribs_rec.pricing_attribute83,
               p_OLD_PRICING_ATTRIBUTE84             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE84             => l_temp_pricing_attribs_rec.pricing_attribute84,
               p_OLD_PRICING_ATTRIBUTE85             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE85             => l_temp_pricing_attribs_rec.pricing_attribute85,
               p_OLD_PRICING_ATTRIBUTE86             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE86             => l_temp_pricing_attribs_rec.pricing_attribute86,
               p_OLD_PRICING_ATTRIBUTE87             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE87             => l_temp_pricing_attribs_rec.pricing_attribute87,
               p_OLD_PRICING_ATTRIBUTE88             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE88             => l_temp_pricing_attribs_rec.pricing_attribute88,
               p_OLD_PRICING_ATTRIBUTE89             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE89             => l_temp_pricing_attribs_rec.pricing_attribute89,
               p_OLD_PRICING_ATTRIBUTE90             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE90             => l_temp_pricing_attribs_rec.pricing_attribute90,
               p_OLD_PRICING_ATTRIBUTE91             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE91             => l_temp_pricing_attribs_rec.pricing_attribute91,
               p_OLD_PRICING_ATTRIBUTE92             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE92             => l_temp_pricing_attribs_rec.pricing_attribute92,
               p_OLD_PRICING_ATTRIBUTE93             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE93             => l_temp_pricing_attribs_rec.pricing_attribute93,
               p_OLD_PRICING_ATTRIBUTE94             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE94             => l_temp_pricing_attribs_rec.pricing_attribute94,
               p_OLD_PRICING_ATTRIBUTE95             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE95             => l_temp_pricing_attribs_rec.pricing_attribute95,
               p_OLD_PRICING_ATTRIBUTE96             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE96             => l_temp_pricing_attribs_rec.pricing_attribute96,
               p_OLD_PRICING_ATTRIBUTE97             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE97             => l_temp_pricing_attribs_rec.pricing_attribute97,
               p_OLD_PRICING_ATTRIBUTE98             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE98             => l_temp_pricing_attribs_rec.pricing_attribute98,
               p_OLD_PRICING_ATTRIBUTE99             => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE99             => l_temp_pricing_attribs_rec.pricing_attribute99,
               p_OLD_PRICING_ATTRIBUTE100            => fnd_api.g_miss_char                           ,
               p_NEW_PRICING_ATTRIBUTE100            => l_temp_pricing_attribs_rec.pricing_attribute100,
               p_OLD_ACTIVE_START_DATE               => fnd_api.g_miss_date                           ,
               p_NEW_ACTIVE_START_DATE               => l_temp_pricing_attribs_rec.active_start_date  ,
               p_OLD_ACTIVE_END_DATE                 => fnd_api.g_miss_date                           ,
               p_NEW_ACTIVE_END_DATE                 => l_temp_pricing_attribs_rec.active_end_date    ,
               p_OLD_CONTEXT                         => fnd_api.g_miss_char                           ,
               p_NEW_CONTEXT                         => l_temp_pricing_attribs_rec.context            ,
               p_OLD_ATTRIBUTE1                      => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE1                      => l_temp_pricing_attribs_rec.ATTRIBUTE1         ,
               p_OLD_ATTRIBUTE2                      => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE2                      => l_temp_pricing_attribs_rec.ATTRIBUTE2         ,
               p_OLD_ATTRIBUTE3                      => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE3                      => l_temp_pricing_attribs_rec.ATTRIBUTE3         ,
               p_OLD_ATTRIBUTE4                      => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE4                      => l_temp_pricing_attribs_rec.ATTRIBUTE4         ,
               p_OLD_ATTRIBUTE5                      => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE5                      => l_temp_pricing_attribs_rec.ATTRIBUTE5         ,
               p_OLD_ATTRIBUTE6                      => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE6                      => l_temp_pricing_attribs_rec.ATTRIBUTE6         ,
               p_OLD_ATTRIBUTE7                      => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE7                      => l_temp_pricing_attribs_rec.ATTRIBUTE7         ,
               p_OLD_ATTRIBUTE8                      => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE8                      => l_temp_pricing_attribs_rec.ATTRIBUTE8         ,
               p_OLD_ATTRIBUTE9                      => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE9                      => l_temp_pricing_attribs_rec.ATTRIBUTE9         ,
               p_OLD_ATTRIBUTE10                     => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE10                     => l_temp_pricing_attribs_rec.ATTRIBUTE10        ,
               p_OLD_ATTRIBUTE11                     => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE11                     => l_temp_pricing_attribs_rec.ATTRIBUTE11        ,
               p_OLD_ATTRIBUTE12                     => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE12                     => l_temp_pricing_attribs_rec.ATTRIBUTE12        ,
               p_OLD_ATTRIBUTE13                     => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE13                     => l_temp_pricing_attribs_rec.ATTRIBUTE13        ,
               p_OLD_ATTRIBUTE14                     => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE14                     => l_temp_pricing_attribs_rec.ATTRIBUTE14        ,
               p_OLD_ATTRIBUTE15                     => fnd_api.g_miss_char                           ,
               p_NEW_ATTRIBUTE15                     => l_temp_pricing_attribs_rec.ATTRIBUTE15        ,
               p_FULL_DUMP_FLAG                      => fnd_api.g_miss_char                           ,
               p_CREATED_BY                          => fnd_api.g_miss_num, -- fnd_global.user_id,
               p_CREATION_DATE                       => fnd_api.g_miss_date                           ,
               p_LAST_UPDATED_BY                     => fnd_global.user_id                            ,
               p_LAST_UPDATE_DATE                    => sysdate                                       ,
               p_LAST_UPDATE_LOGIN                   => fnd_global.user_id                            ,
               p_OBJECT_VERSION_NUMBER               => fnd_api.g_miss_num                            );

        ELSE
          --
             IF    ( l_pricing_hist_csr.old_active_start_date IS NULL
                AND  l_pricing_hist_csr.new_active_start_date IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.active_start_date = l_pricing_attribs_rec.active_start_date )
                      OR ( p_pricing_attribs_rec.active_start_date = fnd_api.g_miss_date ) THEN
                           l_pricing_hist_csr.old_active_start_date := NULL;
                           l_pricing_hist_csr.new_active_start_date := NULL;
                     ELSE
                           l_pricing_hist_csr.old_active_start_date := fnd_api.g_miss_date;
                           l_pricing_hist_csr.new_active_start_date := p_pricing_attribs_rec.active_start_date;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_active_start_date := fnd_api.g_miss_date;
                     l_pricing_hist_csr.new_active_start_date := p_pricing_attribs_rec.active_start_date;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_active_end_date IS NULL
                AND  l_pricing_hist_csr.new_active_end_date IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.active_end_date = l_pricing_attribs_rec.active_end_date )
                      OR ( p_pricing_attribs_rec.active_end_date = fnd_api.g_miss_date ) THEN
                           l_pricing_hist_csr.old_active_end_date := NULL;
                           l_pricing_hist_csr.new_active_end_date := NULL;
                     ELSE
                           l_pricing_hist_csr.old_active_end_date := fnd_api.g_miss_date;
                           l_pricing_hist_csr.new_active_end_date := p_pricing_attribs_rec.active_end_date;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_active_end_date := fnd_api.g_miss_date;
                     l_pricing_hist_csr.new_active_end_date := p_pricing_attribs_rec.active_end_date;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_context IS NULL
                AND  l_pricing_hist_csr.new_context IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.context = l_pricing_attribs_rec.context )
                      OR ( p_pricing_attribs_rec.context = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_context := NULL;
                           l_pricing_hist_csr.new_context := NULL;
                     ELSE
                           l_pricing_hist_csr.old_context := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_context := p_pricing_attribs_rec.context;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_context := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_context := p_pricing_attribs_rec.context;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute1 IS NULL
                AND  l_pricing_hist_csr.new_attribute1 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute1 = l_pricing_attribs_rec.attribute1 )
                      OR ( p_pricing_attribs_rec.attribute1 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute1 := NULL;
                           l_pricing_hist_csr.new_attribute1 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute1 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute1 := p_pricing_attribs_rec.attribute1;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute1 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute1 := p_pricing_attribs_rec.attribute1;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute2 IS NULL
                AND  l_pricing_hist_csr.new_attribute2 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute2 = l_pricing_attribs_rec.attribute2 )
                      OR ( p_pricing_attribs_rec.attribute2 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute2 := NULL;
                           l_pricing_hist_csr.new_attribute2 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute2 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute2 := p_pricing_attribs_rec.attribute2;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute2 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute2 := p_pricing_attribs_rec.attribute2;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute3 IS NULL
                AND  l_pricing_hist_csr.new_attribute3 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute3 = l_pricing_attribs_rec.attribute3 )
                      OR ( p_pricing_attribs_rec.attribute3 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute3 := NULL;
                           l_pricing_hist_csr.new_attribute3 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute3 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute3 := p_pricing_attribs_rec.attribute3;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute3 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute3 := p_pricing_attribs_rec.attribute3;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute4 IS NULL
                AND  l_pricing_hist_csr.new_attribute4 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute4 = l_pricing_attribs_rec.attribute4 )
                      OR ( p_pricing_attribs_rec.attribute4 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute4 := NULL;
                           l_pricing_hist_csr.new_attribute4 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute4 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute4 := p_pricing_attribs_rec.attribute4;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute4 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute4 := p_pricing_attribs_rec.attribute4;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute5 IS NULL
                AND  l_pricing_hist_csr.new_attribute5 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute5 = l_pricing_attribs_rec.attribute5 )
                      OR ( p_pricing_attribs_rec.attribute5 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute5 := NULL;
                           l_pricing_hist_csr.new_attribute5 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute5 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute5 := p_pricing_attribs_rec.attribute5;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute5 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute5 := p_pricing_attribs_rec.attribute5;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute6 IS NULL
                AND  l_pricing_hist_csr.new_attribute6 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute6 = l_pricing_attribs_rec.attribute6 )
                      OR ( p_pricing_attribs_rec.attribute6 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute6 := NULL;
                           l_pricing_hist_csr.new_attribute6 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute6 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute6 := p_pricing_attribs_rec.attribute6;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute6 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute6 := p_pricing_attribs_rec.attribute6;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute7 IS NULL
                AND  l_pricing_hist_csr.new_attribute7 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute7 = l_pricing_attribs_rec.attribute7 )
                      OR ( p_pricing_attribs_rec.attribute7 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute7 := NULL;
                           l_pricing_hist_csr.new_attribute7 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute7 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute7 := p_pricing_attribs_rec.attribute7;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute7 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute7 := p_pricing_attribs_rec.attribute7;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute8 IS NULL
                AND  l_pricing_hist_csr.new_attribute8 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute8 = l_pricing_attribs_rec.attribute8 )
                      OR ( p_pricing_attribs_rec.attribute8 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute8 := NULL;
                           l_pricing_hist_csr.new_attribute8 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute8 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute8 := p_pricing_attribs_rec.attribute8;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute8 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute8 := p_pricing_attribs_rec.attribute8;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute9 IS NULL
                AND  l_pricing_hist_csr.new_attribute9 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute9 = l_pricing_attribs_rec.attribute9 )
                      OR ( p_pricing_attribs_rec.attribute9 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute9 := NULL;
                           l_pricing_hist_csr.new_attribute9 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute9 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute9 := p_pricing_attribs_rec.attribute9;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute9 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute9 := p_pricing_attribs_rec.attribute9;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute10 IS NULL
                AND  l_pricing_hist_csr.new_attribute10 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute10 = l_pricing_attribs_rec.attribute10 )
                      OR ( p_pricing_attribs_rec.attribute10 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute10 := NULL;
                           l_pricing_hist_csr.new_attribute10 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute10 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute10 := p_pricing_attribs_rec.attribute10;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute10 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute10 := p_pricing_attribs_rec.attribute10;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute11 IS NULL
                AND  l_pricing_hist_csr.new_attribute11 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute11 = l_pricing_attribs_rec.attribute11 )
                      OR ( p_pricing_attribs_rec.attribute11 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute11 := NULL;
                           l_pricing_hist_csr.new_attribute11 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute11 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute11 := p_pricing_attribs_rec.attribute11;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute11 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute11 := p_pricing_attribs_rec.attribute11;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute12 IS NULL
                AND  l_pricing_hist_csr.new_attribute12 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute12 = l_pricing_attribs_rec.attribute12 )
                      OR ( p_pricing_attribs_rec.attribute12 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute12 := NULL;
                           l_pricing_hist_csr.new_attribute12 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute12 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute12 := p_pricing_attribs_rec.attribute12;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute12 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute12 := p_pricing_attribs_rec.attribute12;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute13 IS NULL
                AND  l_pricing_hist_csr.new_attribute13 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute13 = l_pricing_attribs_rec.attribute13 )
                      OR ( p_pricing_attribs_rec.attribute13 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute13 := NULL;
                           l_pricing_hist_csr.new_attribute13 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute13 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute13 := p_pricing_attribs_rec.attribute13;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute13 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute13 := p_pricing_attribs_rec.attribute13;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute14 IS NULL
                AND  l_pricing_hist_csr.new_attribute14 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute14 = l_pricing_attribs_rec.attribute14 )
                      OR ( p_pricing_attribs_rec.attribute14 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute14 := NULL;
                           l_pricing_hist_csr.new_attribute14 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute14 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute14 := p_pricing_attribs_rec.attribute14;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute14 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute14 := p_pricing_attribs_rec.attribute14;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_attribute15 IS NULL
                AND  l_pricing_hist_csr.new_attribute15 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.attribute15 = l_pricing_attribs_rec.attribute15 )
                      OR ( p_pricing_attribs_rec.attribute15 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_attribute15 := NULL;
                           l_pricing_hist_csr.new_attribute15 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_attribute15 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_attribute15 := p_pricing_attribs_rec.attribute15;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_attribute15 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_attribute15 := p_pricing_attribs_rec.attribute15;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_context IS NULL
                AND  l_pricing_hist_csr.new_pricing_context IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_context = l_pricing_attribs_rec.pricing_context )
                      OR ( p_pricing_attribs_rec.pricing_context = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_context := NULL;
                           l_pricing_hist_csr.new_pricing_context := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_context := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_context := p_pricing_attribs_rec.pricing_context;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_context := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_context := p_pricing_attribs_rec.pricing_context;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute1 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute1 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute1 = l_pricing_attribs_rec.pricing_attribute1 )
                      OR ( p_pricing_attribs_rec.pricing_attribute1 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute1 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute1 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute1 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute1 := p_pricing_attribs_rec.pricing_attribute1;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute1 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute1 := p_pricing_attribs_rec.pricing_attribute1;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute2 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute2 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute2 = l_pricing_attribs_rec.pricing_attribute2 )
                      OR ( p_pricing_attribs_rec.pricing_attribute2 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute2 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute2 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute2 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute2 := p_pricing_attribs_rec.pricing_attribute2;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute2 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute2 := p_pricing_attribs_rec.pricing_attribute2;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute3 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute3 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute3 = l_pricing_attribs_rec.pricing_attribute3 )
                      OR ( p_pricing_attribs_rec.pricing_attribute3 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute3 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute3 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute3 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute3 := p_pricing_attribs_rec.pricing_attribute3;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute3 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute3 := p_pricing_attribs_rec.pricing_attribute3;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute4 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute4 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute4 = l_pricing_attribs_rec.pricing_attribute4 )
                      OR ( p_pricing_attribs_rec.pricing_attribute4 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute4 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute4 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute4 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute4 := p_pricing_attribs_rec.pricing_attribute4;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute4 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute4 := p_pricing_attribs_rec.pricing_attribute4;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute5 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute5 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute5 = l_pricing_attribs_rec.pricing_attribute5 )
                      OR ( p_pricing_attribs_rec.pricing_attribute5 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute5 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute5 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute5 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute5 := p_pricing_attribs_rec.pricing_attribute5;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute5 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute5 := p_pricing_attribs_rec.pricing_attribute5;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute6 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute6 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute6 = l_pricing_attribs_rec.pricing_attribute6 )
                      OR ( p_pricing_attribs_rec.pricing_attribute6 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute6 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute6 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute6 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute6 := p_pricing_attribs_rec.pricing_attribute6;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute6 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute6 := p_pricing_attribs_rec.pricing_attribute6;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute7 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute7 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute7 = l_pricing_attribs_rec.pricing_attribute7 )
                      OR ( p_pricing_attribs_rec.pricing_attribute7 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute7 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute7 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute7 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute7 := p_pricing_attribs_rec.pricing_attribute7;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute7 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute7 := p_pricing_attribs_rec.pricing_attribute7;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute8 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute8 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute8 = l_pricing_attribs_rec.pricing_attribute8 )
                      OR ( p_pricing_attribs_rec.pricing_attribute8 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute8 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute8 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute8 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute8 := p_pricing_attribs_rec.pricing_attribute8;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute8 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute8 := p_pricing_attribs_rec.pricing_attribute8;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute9 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute9 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute9 = l_pricing_attribs_rec.pricing_attribute9 )
                      OR ( p_pricing_attribs_rec.pricing_attribute9 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute9 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute9 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute9 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute9 := p_pricing_attribs_rec.pricing_attribute9;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute9 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute9 := p_pricing_attribs_rec.pricing_attribute9;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute10 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute10 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute10 = l_pricing_attribs_rec.pricing_attribute10 )
                      OR ( p_pricing_attribs_rec.pricing_attribute10 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute10 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute10 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute10 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute10 := p_pricing_attribs_rec.pricing_attribute10;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute10 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute10 := p_pricing_attribs_rec.pricing_attribute10;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute11 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute11 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute11 = l_pricing_attribs_rec.pricing_attribute11 )
                      OR ( p_pricing_attribs_rec.pricing_attribute11 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute11 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute11 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute11 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute11 := p_pricing_attribs_rec.pricing_attribute11;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute11 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute11 := p_pricing_attribs_rec.pricing_attribute11;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute12 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute12 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute12 = l_pricing_attribs_rec.pricing_attribute12 )
                      OR ( p_pricing_attribs_rec.pricing_attribute12 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute12 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute12 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute12 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute12 := p_pricing_attribs_rec.pricing_attribute12;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute12 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute12 := p_pricing_attribs_rec.pricing_attribute12;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute13 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute13 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute13 = l_pricing_attribs_rec.pricing_attribute13 )
                      OR ( p_pricing_attribs_rec.pricing_attribute13 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute13 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute13 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute13 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute13 := p_pricing_attribs_rec.pricing_attribute13;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute13 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute13 := p_pricing_attribs_rec.pricing_attribute13;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute14 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute14 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute14 = l_pricing_attribs_rec.pricing_attribute14 )
                      OR ( p_pricing_attribs_rec.pricing_attribute14 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute14 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute14 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute14 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute14 := p_pricing_attribs_rec.pricing_attribute14;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute14 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute14 := p_pricing_attribs_rec.pricing_attribute14;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute15 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute15 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute15 = l_pricing_attribs_rec.pricing_attribute15 )
                      OR ( p_pricing_attribs_rec.pricing_attribute15 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute15 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute15 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute15 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute15 := p_pricing_attribs_rec.pricing_attribute15;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute15 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute15 := p_pricing_attribs_rec.pricing_attribute15;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute16 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute16 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute16 = l_pricing_attribs_rec.pricing_attribute16 )
                      OR ( p_pricing_attribs_rec.pricing_attribute16 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute16 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute16 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute16 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute16 := p_pricing_attribs_rec.pricing_attribute16;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute16 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute16 := p_pricing_attribs_rec.pricing_attribute16;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute17 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute17 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute17 = l_pricing_attribs_rec.pricing_attribute17 )
                      OR ( p_pricing_attribs_rec.pricing_attribute17 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute17 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute17 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute17 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute17 := p_pricing_attribs_rec.pricing_attribute17;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute17 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute17 := p_pricing_attribs_rec.pricing_attribute17;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute18 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute18 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute18 = l_pricing_attribs_rec.pricing_attribute18 )
                      OR ( p_pricing_attribs_rec.pricing_attribute18 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute18 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute18 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute18 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute18 := p_pricing_attribs_rec.pricing_attribute18;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute18 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute18 := p_pricing_attribs_rec.pricing_attribute18;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute19 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute19 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute19 = l_pricing_attribs_rec.pricing_attribute19 )
                      OR ( p_pricing_attribs_rec.pricing_attribute19 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute19 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute19 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute19 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute19 := p_pricing_attribs_rec.pricing_attribute19;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute19 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute19 := p_pricing_attribs_rec.pricing_attribute19;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute20 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute20 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute20 = l_pricing_attribs_rec.pricing_attribute20 )
                      OR ( p_pricing_attribs_rec.pricing_attribute20 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute20 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute20 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute20 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute20 := p_pricing_attribs_rec.pricing_attribute20;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute20 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute20 := p_pricing_attribs_rec.pricing_attribute20;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute21 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute21 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute21 = l_pricing_attribs_rec.pricing_attribute21 )
                      OR ( p_pricing_attribs_rec.pricing_attribute21 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute21 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute21 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute21 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute21 := p_pricing_attribs_rec.pricing_attribute21;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute21 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute21 := p_pricing_attribs_rec.pricing_attribute21;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute22 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute22 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute22 = l_pricing_attribs_rec.pricing_attribute22 )
                      OR ( p_pricing_attribs_rec.pricing_attribute22 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute22 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute22 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute22 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute22 := p_pricing_attribs_rec.pricing_attribute22;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute22 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute22 := p_pricing_attribs_rec.pricing_attribute22;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute23 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute23 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute23 = l_pricing_attribs_rec.pricing_attribute23 )
                      OR ( p_pricing_attribs_rec.pricing_attribute23 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute23 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute23 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute23 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute23 := p_pricing_attribs_rec.pricing_attribute23;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute23 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute23 := p_pricing_attribs_rec.pricing_attribute23;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute24 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute24 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute24 = l_pricing_attribs_rec.pricing_attribute24 )
                      OR ( p_pricing_attribs_rec.pricing_attribute24 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute24 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute24 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute24 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute24 := p_pricing_attribs_rec.pricing_attribute24;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute24 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute24 := p_pricing_attribs_rec.pricing_attribute24;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute25 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute25 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute25 = l_pricing_attribs_rec.pricing_attribute25 )
                      OR ( p_pricing_attribs_rec.pricing_attribute25 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute25 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute25 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute25 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute25 := p_pricing_attribs_rec.pricing_attribute25;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute25 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute25 := p_pricing_attribs_rec.pricing_attribute25;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute26 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute26 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute26 = l_pricing_attribs_rec.pricing_attribute26 )
                      OR ( p_pricing_attribs_rec.pricing_attribute26 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute26 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute26 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute26 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute26 := p_pricing_attribs_rec.pricing_attribute26;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute26 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute26 := p_pricing_attribs_rec.pricing_attribute26;
             END IF;
		   --
             IF    ( l_pricing_hist_csr.old_pricing_attribute27 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute27 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute27 = l_pricing_attribs_rec.pricing_attribute27 )
                      OR ( p_pricing_attribs_rec.pricing_attribute27 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute27 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute27 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute27 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute27 := p_pricing_attribs_rec.pricing_attribute27;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute27 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute27 := p_pricing_attribs_rec.pricing_attribute27;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute28 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute28 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute28 = l_pricing_attribs_rec.pricing_attribute28 )
                      OR ( p_pricing_attribs_rec.pricing_attribute28 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute28 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute28 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute28 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute28 := p_pricing_attribs_rec.pricing_attribute28;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute28 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute28 := p_pricing_attribs_rec.pricing_attribute28;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute29 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute29 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute29 = l_pricing_attribs_rec.pricing_attribute29 )
                      OR ( p_pricing_attribs_rec.pricing_attribute29 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute29 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute29 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute29 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute29 := p_pricing_attribs_rec.pricing_attribute29;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute29 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute29 := p_pricing_attribs_rec.pricing_attribute29;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute30 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute30 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute30 = l_pricing_attribs_rec.pricing_attribute30 )
                      OR ( p_pricing_attribs_rec.pricing_attribute30 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute30 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute30 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute30 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute30 := p_pricing_attribs_rec.pricing_attribute30;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute30 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute30 := p_pricing_attribs_rec.pricing_attribute30;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute31 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute31 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute31 = l_pricing_attribs_rec.pricing_attribute31 )
                      OR ( p_pricing_attribs_rec.pricing_attribute31 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute31 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute31 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute31 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute31 := p_pricing_attribs_rec.pricing_attribute31;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute31 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute31 := p_pricing_attribs_rec.pricing_attribute31;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute32 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute32 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute32 = l_pricing_attribs_rec.pricing_attribute32 )
                      OR ( p_pricing_attribs_rec.pricing_attribute32 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute32 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute32 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute32 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute32 := p_pricing_attribs_rec.pricing_attribute32;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute32 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute32 := p_pricing_attribs_rec.pricing_attribute32;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute33 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute33 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute33 = l_pricing_attribs_rec.pricing_attribute33 )
                      OR ( p_pricing_attribs_rec.pricing_attribute33 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute33 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute33 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute33 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute33 := p_pricing_attribs_rec.pricing_attribute33;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute33 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute33 := p_pricing_attribs_rec.pricing_attribute33;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute34 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute34 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute34 = l_pricing_attribs_rec.pricing_attribute34 )
                      OR ( p_pricing_attribs_rec.pricing_attribute34 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute34 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute34 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute34 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute34 := p_pricing_attribs_rec.pricing_attribute34;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute34 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute34 := p_pricing_attribs_rec.pricing_attribute34;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute35 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute35 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute35 = l_pricing_attribs_rec.pricing_attribute35 )
                      OR ( p_pricing_attribs_rec.pricing_attribute35 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute35 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute35 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute35 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute35 := p_pricing_attribs_rec.pricing_attribute35;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute35 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute35 := p_pricing_attribs_rec.pricing_attribute35;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute36 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute36 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute36 = l_pricing_attribs_rec.pricing_attribute36 )
                      OR ( p_pricing_attribs_rec.pricing_attribute36 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute36 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute36 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute36 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute36 := p_pricing_attribs_rec.pricing_attribute36;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute36 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute36 := p_pricing_attribs_rec.pricing_attribute36;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute37 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute37 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute37 = l_pricing_attribs_rec.pricing_attribute37 )
                      OR ( p_pricing_attribs_rec.pricing_attribute37 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute37 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute37 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute37 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute37 := p_pricing_attribs_rec.pricing_attribute37;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute37 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute37 := p_pricing_attribs_rec.pricing_attribute37;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute38 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute38 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute38 = l_pricing_attribs_rec.pricing_attribute38 )
                      OR ( p_pricing_attribs_rec.pricing_attribute38 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute38 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute38 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute38 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute38 := p_pricing_attribs_rec.pricing_attribute38;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute38 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute38 := p_pricing_attribs_rec.pricing_attribute38;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute39 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute39 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute39 = l_pricing_attribs_rec.pricing_attribute39 )
                      OR ( p_pricing_attribs_rec.pricing_attribute39 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute39 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute39 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute39 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute39 := p_pricing_attribs_rec.pricing_attribute39;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute39 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute39 := p_pricing_attribs_rec.pricing_attribute39;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute40 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute40 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute40 = l_pricing_attribs_rec.pricing_attribute40 )
                      OR ( p_pricing_attribs_rec.pricing_attribute40 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute40 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute40 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute40 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute40 := p_pricing_attribs_rec.pricing_attribute40;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute40 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute40 := p_pricing_attribs_rec.pricing_attribute40;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute41 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute41 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute41 = l_pricing_attribs_rec.pricing_attribute41 )
                      OR ( p_pricing_attribs_rec.pricing_attribute41 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute41 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute41 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute41 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute41 := p_pricing_attribs_rec.pricing_attribute41;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute41 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute41 := p_pricing_attribs_rec.pricing_attribute41;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute42 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute42 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute42 = l_pricing_attribs_rec.pricing_attribute42 )
                      OR ( p_pricing_attribs_rec.pricing_attribute42 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute42 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute42 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute42 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute42 := p_pricing_attribs_rec.pricing_attribute42;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute42 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute42 := p_pricing_attribs_rec.pricing_attribute42;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute43 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute43 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute43 = l_pricing_attribs_rec.pricing_attribute43 )
                      OR ( p_pricing_attribs_rec.pricing_attribute43 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute43 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute43 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute43 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute43 := p_pricing_attribs_rec.pricing_attribute43;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute43 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute43 := p_pricing_attribs_rec.pricing_attribute43;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute44 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute44 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute44 = l_pricing_attribs_rec.pricing_attribute44 )
                      OR ( p_pricing_attribs_rec.pricing_attribute44 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute44 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute44 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute44 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute44 := p_pricing_attribs_rec.pricing_attribute44;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute44 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute44 := p_pricing_attribs_rec.pricing_attribute44;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute45 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute45 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute45 = l_pricing_attribs_rec.pricing_attribute45 )
                      OR ( p_pricing_attribs_rec.pricing_attribute45 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute45 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute45 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute45 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute45 := p_pricing_attribs_rec.pricing_attribute45;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute45 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute45 := p_pricing_attribs_rec.pricing_attribute45;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute46 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute46 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute46 = l_pricing_attribs_rec.pricing_attribute46 )
                      OR ( p_pricing_attribs_rec.pricing_attribute46 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute46 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute46 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute46 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute46 := p_pricing_attribs_rec.pricing_attribute46;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute46 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute46 := p_pricing_attribs_rec.pricing_attribute46;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute47 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute47 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute47 = l_pricing_attribs_rec.pricing_attribute47 )
                      OR ( p_pricing_attribs_rec.pricing_attribute47 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute47 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute47 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute47 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute47 := p_pricing_attribs_rec.pricing_attribute47;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute47 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute47 := p_pricing_attribs_rec.pricing_attribute47;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute48 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute48 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute48 = l_pricing_attribs_rec.pricing_attribute48 )
                      OR ( p_pricing_attribs_rec.pricing_attribute48 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute48 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute48 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute48 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute48 := p_pricing_attribs_rec.pricing_attribute48;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute48 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute48 := p_pricing_attribs_rec.pricing_attribute48;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute49 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute49 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute49 = l_pricing_attribs_rec.pricing_attribute49 )
                      OR ( p_pricing_attribs_rec.pricing_attribute49 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute49 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute49 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute49 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute49 := p_pricing_attribs_rec.pricing_attribute49;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute49 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute49 := p_pricing_attribs_rec.pricing_attribute49;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute50 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute50 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute50 = l_pricing_attribs_rec.pricing_attribute50 )
                      OR ( p_pricing_attribs_rec.pricing_attribute50 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute50 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute50 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute50 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute50 := p_pricing_attribs_rec.pricing_attribute50;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute50 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute50 := p_pricing_attribs_rec.pricing_attribute50;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute51 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute51 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute51 = l_pricing_attribs_rec.pricing_attribute51 )
                      OR ( p_pricing_attribs_rec.pricing_attribute51 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute51 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute51 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute51 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute51 := p_pricing_attribs_rec.pricing_attribute51;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute51 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute51 := p_pricing_attribs_rec.pricing_attribute51;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute52 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute52 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute52 = l_pricing_attribs_rec.pricing_attribute52 )
                      OR ( p_pricing_attribs_rec.pricing_attribute52 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute52 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute52 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute52 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute52 := p_pricing_attribs_rec.pricing_attribute52;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute52 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute52 := p_pricing_attribs_rec.pricing_attribute52;
             END IF;
		   --
             IF    ( l_pricing_hist_csr.old_pricing_attribute53 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute53 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute53 = l_pricing_attribs_rec.pricing_attribute53 )
                      OR ( p_pricing_attribs_rec.pricing_attribute53 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute53 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute53 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute53 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute53 := p_pricing_attribs_rec.pricing_attribute53;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute53 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute53 := p_pricing_attribs_rec.pricing_attribute53;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute54 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute54 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute54 = l_pricing_attribs_rec.pricing_attribute54 )
                      OR ( p_pricing_attribs_rec.pricing_attribute54 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute54 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute54 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute54 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute54 := p_pricing_attribs_rec.pricing_attribute54;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute54 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute54 := p_pricing_attribs_rec.pricing_attribute54;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute55 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute55 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute55 = l_pricing_attribs_rec.pricing_attribute55 )
                      OR ( p_pricing_attribs_rec.pricing_attribute55 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute55 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute55 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute55 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute55 := p_pricing_attribs_rec.pricing_attribute55;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute55 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute55 := p_pricing_attribs_rec.pricing_attribute55;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute56 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute56 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute56 = l_pricing_attribs_rec.pricing_attribute56 )
                      OR ( p_pricing_attribs_rec.pricing_attribute56 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute56 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute56 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute56 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute56 := p_pricing_attribs_rec.pricing_attribute56;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute56 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute56 := p_pricing_attribs_rec.pricing_attribute56;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute57 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute57 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute57 = l_pricing_attribs_rec.pricing_attribute57 )
                      OR ( p_pricing_attribs_rec.pricing_attribute57 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute57 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute57 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute57 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute57 := p_pricing_attribs_rec.pricing_attribute57;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute57 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute57 := p_pricing_attribs_rec.pricing_attribute57;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute58 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute58 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute58 = l_pricing_attribs_rec.pricing_attribute58 )
                      OR ( p_pricing_attribs_rec.pricing_attribute58 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute58 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute58 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute58 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute58 := p_pricing_attribs_rec.pricing_attribute58;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute58 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute58 := p_pricing_attribs_rec.pricing_attribute58;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute59 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute59 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute59 = l_pricing_attribs_rec.pricing_attribute59 )
                      OR ( p_pricing_attribs_rec.pricing_attribute59 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute59 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute59 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute59 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute59 := p_pricing_attribs_rec.pricing_attribute59;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute59 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute59 := p_pricing_attribs_rec.pricing_attribute59;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute60 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute60 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute60 = l_pricing_attribs_rec.pricing_attribute60 )
                      OR ( p_pricing_attribs_rec.pricing_attribute60 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute60 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute60 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute60 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute60 := p_pricing_attribs_rec.pricing_attribute60;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute60 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute60 := p_pricing_attribs_rec.pricing_attribute60;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute61 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute61 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute61 = l_pricing_attribs_rec.pricing_attribute61 )
                      OR ( p_pricing_attribs_rec.pricing_attribute61 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute61 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute61 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute61 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute61 := p_pricing_attribs_rec.pricing_attribute61;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute61 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute61 := p_pricing_attribs_rec.pricing_attribute61;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute62 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute62 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute62 = l_pricing_attribs_rec.pricing_attribute62 )
                      OR ( p_pricing_attribs_rec.pricing_attribute62 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute62 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute62 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute62 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute62 := p_pricing_attribs_rec.pricing_attribute62;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute62 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute62 := p_pricing_attribs_rec.pricing_attribute62;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute63 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute63 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute63 = l_pricing_attribs_rec.pricing_attribute63 )
                      OR ( p_pricing_attribs_rec.pricing_attribute63 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute63 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute63 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute63 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute63 := p_pricing_attribs_rec.pricing_attribute63;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute63 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute63 := p_pricing_attribs_rec.pricing_attribute63;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute64 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute64 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute64 = l_pricing_attribs_rec.pricing_attribute64 )
                      OR ( p_pricing_attribs_rec.pricing_attribute64 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute64 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute64 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute64 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute64 := p_pricing_attribs_rec.pricing_attribute64;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute64 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute64 := p_pricing_attribs_rec.pricing_attribute64;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute65 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute65 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute65 = l_pricing_attribs_rec.pricing_attribute65 )
                      OR ( p_pricing_attribs_rec.pricing_attribute65 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute65 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute65 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute65 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute65 := p_pricing_attribs_rec.pricing_attribute65;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute65 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute65 := p_pricing_attribs_rec.pricing_attribute65;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute66 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute66 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute66 = l_pricing_attribs_rec.pricing_attribute66 )
                      OR ( p_pricing_attribs_rec.pricing_attribute66 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute66 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute66 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute66 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute66 := p_pricing_attribs_rec.pricing_attribute66;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute66 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute66 := p_pricing_attribs_rec.pricing_attribute66;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute67 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute67 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute67 = l_pricing_attribs_rec.pricing_attribute67 )
                      OR ( p_pricing_attribs_rec.pricing_attribute67 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute67 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute67 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute67 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute67 := p_pricing_attribs_rec.pricing_attribute67;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute67 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute67 := p_pricing_attribs_rec.pricing_attribute67;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute68 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute68 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute68 = l_pricing_attribs_rec.pricing_attribute68 )
                      OR ( p_pricing_attribs_rec.pricing_attribute68 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute68 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute68 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute68 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute68 := p_pricing_attribs_rec.pricing_attribute68;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute68 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute68 := p_pricing_attribs_rec.pricing_attribute68;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute69 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute69 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute69 = l_pricing_attribs_rec.pricing_attribute69 )
                      OR ( p_pricing_attribs_rec.pricing_attribute69 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute69 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute69 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute69 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute69 := p_pricing_attribs_rec.pricing_attribute69;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute69 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute69 := p_pricing_attribs_rec.pricing_attribute69;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute70 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute70 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute70 = l_pricing_attribs_rec.pricing_attribute70 )
                      OR ( p_pricing_attribs_rec.pricing_attribute70 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute70 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute70 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute70 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute70 := p_pricing_attribs_rec.pricing_attribute70;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute70 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute70 := p_pricing_attribs_rec.pricing_attribute70;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute71 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute71 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute71 = l_pricing_attribs_rec.pricing_attribute71 )
                      OR ( p_pricing_attribs_rec.pricing_attribute71 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute71 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute71 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute71 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute71 := p_pricing_attribs_rec.pricing_attribute71;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute71 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute71 := p_pricing_attribs_rec.pricing_attribute71;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute72 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute72 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute72 = l_pricing_attribs_rec.pricing_attribute72 )
                      OR ( p_pricing_attribs_rec.pricing_attribute72 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute72 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute72 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute72 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute72 := p_pricing_attribs_rec.pricing_attribute72;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute72 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute72 := p_pricing_attribs_rec.pricing_attribute72;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute73 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute73 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute73 = l_pricing_attribs_rec.pricing_attribute73 )
                      OR ( p_pricing_attribs_rec.pricing_attribute73 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute73 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute73 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute73 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute73 := p_pricing_attribs_rec.pricing_attribute73;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute73 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute73 := p_pricing_attribs_rec.pricing_attribute73;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute74 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute74 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute74 = l_pricing_attribs_rec.pricing_attribute74 )
                      OR ( p_pricing_attribs_rec.pricing_attribute74 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute74 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute74 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute74 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute74 := p_pricing_attribs_rec.pricing_attribute74;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute74 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute74 := p_pricing_attribs_rec.pricing_attribute74;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute75 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute75 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute75 = l_pricing_attribs_rec.pricing_attribute75 )
                      OR ( p_pricing_attribs_rec.pricing_attribute75 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute75 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute75 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute75 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute75 := p_pricing_attribs_rec.pricing_attribute75;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute75 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute75 := p_pricing_attribs_rec.pricing_attribute75;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute76 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute76 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute76 = l_pricing_attribs_rec.pricing_attribute76 )
                      OR ( p_pricing_attribs_rec.pricing_attribute76 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute76 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute76 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute76 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute76 := p_pricing_attribs_rec.pricing_attribute76;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute76 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute76 := p_pricing_attribs_rec.pricing_attribute76;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute77 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute77 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute77 = l_pricing_attribs_rec.pricing_attribute77 )
                      OR ( p_pricing_attribs_rec.pricing_attribute77 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute77 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute77 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute77 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute77 := p_pricing_attribs_rec.pricing_attribute77;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute77 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute77 := p_pricing_attribs_rec.pricing_attribute77;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute78 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute78 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute78 = l_pricing_attribs_rec.pricing_attribute78 )
                      OR ( p_pricing_attribs_rec.pricing_attribute78 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute78 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute78 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute78 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute78 := p_pricing_attribs_rec.pricing_attribute78;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute78 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute78 := p_pricing_attribs_rec.pricing_attribute78;
             END IF;
		   --
             IF    ( l_pricing_hist_csr.old_pricing_attribute79 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute79 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute79 = l_pricing_attribs_rec.pricing_attribute79 )
                      OR ( p_pricing_attribs_rec.pricing_attribute79 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute79 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute79 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute79 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute79 := p_pricing_attribs_rec.pricing_attribute79;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute79 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute79 := p_pricing_attribs_rec.pricing_attribute79;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute80 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute80 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute80 = l_pricing_attribs_rec.pricing_attribute80 )
                      OR ( p_pricing_attribs_rec.pricing_attribute80 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute80 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute80 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute80 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute80 := p_pricing_attribs_rec.pricing_attribute80;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute80 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute80 := p_pricing_attribs_rec.pricing_attribute80;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute81 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute81 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute81 = l_pricing_attribs_rec.pricing_attribute81 )
                      OR ( p_pricing_attribs_rec.pricing_attribute81 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute81 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute81 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute81 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute81 := p_pricing_attribs_rec.pricing_attribute81;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute81 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute81 := p_pricing_attribs_rec.pricing_attribute81;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute82 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute82 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute82 = l_pricing_attribs_rec.pricing_attribute82 )
                      OR ( p_pricing_attribs_rec.pricing_attribute82 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute82 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute82 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute82 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute82 := p_pricing_attribs_rec.pricing_attribute82;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute82 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute82 := p_pricing_attribs_rec.pricing_attribute82;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute83 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute83 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute83 = l_pricing_attribs_rec.pricing_attribute83 )
                      OR ( p_pricing_attribs_rec.pricing_attribute83 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute83 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute83 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute83 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute83 := p_pricing_attribs_rec.pricing_attribute83;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute83 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute83 := p_pricing_attribs_rec.pricing_attribute83;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute84 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute84 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute84 = l_pricing_attribs_rec.pricing_attribute84 )
                      OR ( p_pricing_attribs_rec.pricing_attribute84 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute84 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute84 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute84 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute84 := p_pricing_attribs_rec.pricing_attribute84;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute84 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute84 := p_pricing_attribs_rec.pricing_attribute84;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute85 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute85 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute85 = l_pricing_attribs_rec.pricing_attribute85 )
                      OR ( p_pricing_attribs_rec.pricing_attribute85 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute85 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute85 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute85 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute85 := p_pricing_attribs_rec.pricing_attribute85;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute85 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute85 := p_pricing_attribs_rec.pricing_attribute85;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute86 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute86 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute86 = l_pricing_attribs_rec.pricing_attribute86 )
                      OR ( p_pricing_attribs_rec.pricing_attribute86 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute86 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute86 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute86 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute86 := p_pricing_attribs_rec.pricing_attribute86;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute86 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute86 := p_pricing_attribs_rec.pricing_attribute86;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute87 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute87 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute87 = l_pricing_attribs_rec.pricing_attribute87 )
                      OR ( p_pricing_attribs_rec.pricing_attribute87 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute87 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute87 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute87 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute87 := p_pricing_attribs_rec.pricing_attribute87;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute87 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute87 := p_pricing_attribs_rec.pricing_attribute87;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute88 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute88 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute88 = l_pricing_attribs_rec.pricing_attribute88 )
                      OR ( p_pricing_attribs_rec.pricing_attribute88 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute88 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute88 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute88 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute88 := p_pricing_attribs_rec.pricing_attribute88;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute88 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute88 := p_pricing_attribs_rec.pricing_attribute88;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute89 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute89 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute89 = l_pricing_attribs_rec.pricing_attribute89 )
                      OR ( p_pricing_attribs_rec.pricing_attribute89 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute89 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute89 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute89 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute89 := p_pricing_attribs_rec.pricing_attribute89;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute89 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute89 := p_pricing_attribs_rec.pricing_attribute89;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute90 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute90 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute90 = l_pricing_attribs_rec.pricing_attribute90 )
                      OR ( p_pricing_attribs_rec.pricing_attribute90 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute90 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute90 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute90 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute90 := p_pricing_attribs_rec.pricing_attribute90;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute90 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute90 := p_pricing_attribs_rec.pricing_attribute90;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute91 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute91 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute91 = l_pricing_attribs_rec.pricing_attribute91 )
                      OR ( p_pricing_attribs_rec.pricing_attribute91 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute91 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute91 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute91 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute91 := p_pricing_attribs_rec.pricing_attribute91;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute91 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute91 := p_pricing_attribs_rec.pricing_attribute91;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute92 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute92 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute92 = l_pricing_attribs_rec.pricing_attribute92 )
                      OR ( p_pricing_attribs_rec.pricing_attribute92 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute92 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute92 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute92 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute92 := p_pricing_attribs_rec.pricing_attribute92;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute92 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute92 := p_pricing_attribs_rec.pricing_attribute92;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute93 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute93 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute93 = l_pricing_attribs_rec.pricing_attribute93 )
                      OR ( p_pricing_attribs_rec.pricing_attribute93 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute93 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute93 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute93 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute93 := p_pricing_attribs_rec.pricing_attribute93;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute93 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute93 := p_pricing_attribs_rec.pricing_attribute93;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute94 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute94 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute94 = l_pricing_attribs_rec.pricing_attribute94 )
                      OR ( p_pricing_attribs_rec.pricing_attribute94 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute94 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute94 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute94 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute94 := p_pricing_attribs_rec.pricing_attribute94;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute94 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute94 := p_pricing_attribs_rec.pricing_attribute94;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute95 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute95 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute95 = l_pricing_attribs_rec.pricing_attribute95 )
                      OR ( p_pricing_attribs_rec.pricing_attribute95 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute95 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute95 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute95 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute95 := p_pricing_attribs_rec.pricing_attribute95;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute95 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute95 := p_pricing_attribs_rec.pricing_attribute95;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute96 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute96 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute96 = l_pricing_attribs_rec.pricing_attribute96 )
                      OR ( p_pricing_attribs_rec.pricing_attribute96 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute96 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute96 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute96 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute96 := p_pricing_attribs_rec.pricing_attribute96;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute96 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute96 := p_pricing_attribs_rec.pricing_attribute96;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute97 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute97 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute97 = l_pricing_attribs_rec.pricing_attribute97 )
                      OR ( p_pricing_attribs_rec.pricing_attribute97 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute97 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute97 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute97 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute97 := p_pricing_attribs_rec.pricing_attribute97;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute97 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute97 := p_pricing_attribs_rec.pricing_attribute97;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute98 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute98 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute98 = l_pricing_attribs_rec.pricing_attribute98 )
                      OR ( p_pricing_attribs_rec.pricing_attribute98 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute98 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute98 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute98 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute98 := p_pricing_attribs_rec.pricing_attribute98;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute98 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute98 := p_pricing_attribs_rec.pricing_attribute98;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute99 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute99 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute99 = l_pricing_attribs_rec.pricing_attribute99 )
                      OR ( p_pricing_attribs_rec.pricing_attribute99 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute99 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute99 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute99 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute99 := p_pricing_attribs_rec.pricing_attribute99;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute99 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute99 := p_pricing_attribs_rec.pricing_attribute99;
             END IF;
             --
             IF    ( l_pricing_hist_csr.old_pricing_attribute100 IS NULL
                AND  l_pricing_hist_csr.new_pricing_attribute100 IS NULL ) THEN
                     IF  ( p_pricing_attribs_rec.pricing_attribute100 = l_pricing_attribs_rec.pricing_attribute100 )
                      OR ( p_pricing_attribs_rec.pricing_attribute100 = fnd_api.g_miss_char ) THEN
                           l_pricing_hist_csr.old_pricing_attribute100 := NULL;
                           l_pricing_hist_csr.new_pricing_attribute100 := NULL;
                     ELSE
                           l_pricing_hist_csr.old_pricing_attribute100 := fnd_api.g_miss_char;
                           l_pricing_hist_csr.new_pricing_attribute100 := p_pricing_attribs_rec.pricing_attribute100;
                     END IF;
             ELSE
                     l_pricing_hist_csr.old_pricing_attribute100 := fnd_api.g_miss_char;
                     l_pricing_hist_csr.new_pricing_attribute100 := p_pricing_attribs_rec.pricing_attribute100;
             END IF;
             --

         CSI_I_PRICING_ATTRIBS_H_PKG.Update_Row(
               p_price_attrib_history_id             => l_pricing_hist_id                             ,
               p_pricing_attribute_id                => fnd_api.g_miss_num                            ,
               p_transaction_id                      => fnd_api.g_miss_num                            ,
               p_old_pricing_context                 => l_pricing_hist_csr.old_pricing_context        ,
               p_new_pricing_context                 => l_pricing_hist_csr.new_pricing_context    ,
               p_old_pricing_attribute1              => l_pricing_hist_csr.old_pricing_attribute1     ,
               p_new_pricing_attribute1              => l_pricing_hist_csr.new_pricing_attribute1 ,
               p_old_pricing_attribute2              => l_pricing_hist_csr.old_pricing_attribute2     ,
               p_new_pricing_attribute2              => l_pricing_hist_csr.new_pricing_attribute2 ,
               p_old_pricing_attribute3              => l_pricing_hist_csr.old_pricing_attribute3     ,
               p_new_pricing_attribute3              => l_pricing_hist_csr.new_pricing_attribute3 ,
               p_old_pricing_attribute4              => l_pricing_hist_csr.old_pricing_attribute4     ,
               p_new_pricing_attribute4              => l_pricing_hist_csr.new_pricing_attribute4 ,
               p_old_pricing_attribute5              => l_pricing_hist_csr.old_pricing_attribute5     ,
               p_new_pricing_attribute5              => l_pricing_hist_csr.new_pricing_attribute5 ,
               p_old_pricing_attribute6              => l_pricing_hist_csr.old_pricing_attribute6     ,
               p_new_pricing_attribute6              => l_pricing_hist_csr.new_pricing_attribute6 ,
               p_old_pricing_attribute7              => l_pricing_hist_csr.old_pricing_attribute7     ,
               p_new_pricing_attribute7              => l_pricing_hist_csr.new_pricing_attribute7 ,
               p_old_pricing_attribute8              => l_pricing_hist_csr.old_pricing_attribute8     ,
               p_new_pricing_attribute8              => l_pricing_hist_csr.new_pricing_attribute8 ,
               p_old_pricing_attribute9              => l_pricing_hist_csr.old_pricing_attribute9     ,
               p_new_pricing_attribute9              => l_pricing_hist_csr.new_pricing_attribute9 ,
               p_old_pricing_attribute10             => l_pricing_hist_csr.old_pricing_attribute10    ,
               p_new_pricing_attribute10             => l_pricing_hist_csr.new_pricing_attribute10,
               p_old_pricing_attribute11             => l_pricing_hist_csr.old_pricing_attribute11    ,
               p_new_pricing_attribute11             => l_pricing_hist_csr.new_pricing_attribute11,
               p_old_pricing_attribute12             => l_pricing_hist_csr.old_pricing_attribute12    ,
               p_new_pricing_attribute12             => l_pricing_hist_csr.new_pricing_attribute12,
               p_old_pricing_attribute13             => l_pricing_hist_csr.old_pricing_attribute13    ,
               p_new_pricing_attribute13             => l_pricing_hist_csr.new_pricing_attribute13,
               p_old_pricing_attribute14             => l_pricing_hist_csr.old_pricing_attribute14    ,
               p_new_pricing_attribute14             => l_pricing_hist_csr.new_pricing_attribute14,
               p_old_pricing_attribute15             => l_pricing_hist_csr.old_pricing_attribute15    ,
               p_new_pricing_attribute15             => l_pricing_hist_csr.new_pricing_attribute15,
               p_old_pricing_attribute16             => l_pricing_hist_csr.old_pricing_attribute16    ,
               p_new_pricing_attribute16             => l_pricing_hist_csr.new_pricing_attribute16,
               p_old_pricing_attribute17             => l_pricing_hist_csr.old_pricing_attribute17    ,
               p_new_pricing_attribute17             => l_pricing_hist_csr.new_pricing_attribute17,
               p_old_pricing_attribute18             => l_pricing_hist_csr.old_pricing_attribute18    ,
               p_new_pricing_attribute18             => l_pricing_hist_csr.new_pricing_attribute18,
               p_old_pricing_attribute19             => l_pricing_hist_csr.old_pricing_attribute19    ,
               p_new_pricing_attribute19             => l_pricing_hist_csr.new_pricing_attribute19,
               p_old_pricing_attribute20             => l_pricing_hist_csr.old_pricing_attribute20    ,
               p_new_pricing_attribute20             => l_pricing_hist_csr.new_pricing_attribute20,
               p_old_pricing_attribute21             => l_pricing_hist_csr.old_pricing_attribute21    ,
               p_new_pricing_attribute21             => l_pricing_hist_csr.new_pricing_attribute21,
               p_old_pricing_attribute22             => l_pricing_hist_csr.old_pricing_attribute22    ,
               p_new_pricing_attribute22             => l_pricing_hist_csr.new_pricing_attribute22,
               p_old_pricing_attribute23             => l_pricing_hist_csr.old_pricing_attribute23    ,
               p_new_pricing_attribute23             => l_pricing_hist_csr.new_pricing_attribute23,
               p_old_pricing_attribute24             => l_pricing_hist_csr.old_pricing_attribute24    ,
               p_new_pricing_attribute24             => l_pricing_hist_csr.new_pricing_attribute24,
               p_new_pricing_attribute25             => l_pricing_hist_csr.old_pricing_attribute25    ,
               p_old_pricing_attribute25             => l_pricing_hist_csr.new_pricing_attribute25,
               p_old_pricing_attribute26             => l_pricing_hist_csr.old_pricing_attribute26    ,
               p_new_pricing_attribute26             => l_pricing_hist_csr.new_pricing_attribute26,
               p_old_pricing_attribute27             => l_pricing_hist_csr.old_pricing_attribute27    ,
               p_new_pricing_attribute27             => l_pricing_hist_csr.new_pricing_attribute27,
               p_old_pricing_attribute28             => l_pricing_hist_csr.old_pricing_attribute28    ,
               p_new_pricing_attribute28             => l_pricing_hist_csr.new_pricing_attribute28,
               p_old_pricing_attribute29             => l_pricing_hist_csr.old_pricing_attribute29    ,
               p_new_pricing_attribute29             => l_pricing_hist_csr.new_pricing_attribute29,
               p_old_pricing_attribute30             => l_pricing_hist_csr.old_pricing_attribute30    ,
               p_new_pricing_attribute30             => l_pricing_hist_csr.new_pricing_attribute30,
               p_old_pricing_attribute31             => l_pricing_hist_csr.old_pricing_attribute31    ,
               p_new_pricing_attribute31             => l_pricing_hist_csr.new_pricing_attribute31,
               p_old_pricing_attribute32             => l_pricing_hist_csr.old_pricing_attribute32    ,
               p_new_pricing_attribute32             => l_pricing_hist_csr.new_pricing_attribute32,
               p_old_pricing_attribute33             => l_pricing_hist_csr.old_pricing_attribute33    ,
               p_new_pricing_attribute33             => l_pricing_hist_csr.new_pricing_attribute33,
               p_old_pricing_attribute34             => l_pricing_hist_csr.old_pricing_attribute34    ,
               p_new_pricing_attribute34             => l_pricing_hist_csr.new_pricing_attribute34,
               p_old_pricing_attribute35             => l_pricing_hist_csr.old_pricing_attribute35    ,
               p_new_pricing_attribute35             => l_pricing_hist_csr.new_pricing_attribute35,
               p_old_pricing_attribute36             => l_pricing_hist_csr.old_pricing_attribute36    ,
               p_new_pricing_attribute36             => l_pricing_hist_csr.new_pricing_attribute36,
               p_old_pricing_attribute37             => l_pricing_hist_csr.old_pricing_attribute37    ,
               p_new_pricing_attribute37             => l_pricing_hist_csr.new_pricing_attribute37,
               p_old_pricing_attribute38             => l_pricing_hist_csr.old_pricing_attribute38    ,
               p_new_pricing_attribute38             => l_pricing_hist_csr.new_pricing_attribute38,
               p_old_pricing_attribute39             => l_pricing_hist_csr.old_pricing_attribute39    ,
               p_new_pricing_attribute39             => l_pricing_hist_csr.new_pricing_attribute39,
               p_old_pricing_attribute40             => l_pricing_hist_csr.old_pricing_attribute40    ,
               p_new_pricing_attribute40             => l_pricing_hist_csr.new_pricing_attribute40,
               p_old_pricing_attribute41             => l_pricing_hist_csr.old_pricing_attribute41    ,
               p_new_pricing_attribute41             => l_pricing_hist_csr.new_pricing_attribute41,
               p_old_pricing_attribute42             => l_pricing_hist_csr.old_pricing_attribute42    ,
               p_new_pricing_attribute42             => l_pricing_hist_csr.new_pricing_attribute42,
               p_old_pricing_attribute43             => l_pricing_hist_csr.old_pricing_attribute43    ,
               p_new_pricing_attribute43             => l_pricing_hist_csr.new_pricing_attribute43,
               p_old_pricing_attribute44             => l_pricing_hist_csr.old_pricing_attribute44    ,
               p_new_pricing_attribute44             => l_pricing_hist_csr.new_pricing_attribute44,
               p_old_pricing_attribute45             => l_pricing_hist_csr.old_pricing_attribute45    ,
               p_new_pricing_attribute45             => l_pricing_hist_csr.new_pricing_attribute45,
               p_old_pricing_attribute46             => l_pricing_hist_csr.old_pricing_attribute46    ,
               p_new_pricing_attribute46             => l_pricing_hist_csr.new_pricing_attribute46,
               p_old_pricing_attribute47             => l_pricing_hist_csr.old_pricing_attribute47    ,
               p_new_pricing_attribute47             => l_pricing_hist_csr.new_pricing_attribute47,
               p_old_pricing_attribute48             => l_pricing_hist_csr.old_pricing_attribute48    ,
               p_new_pricing_attribute48             => l_pricing_hist_csr.new_pricing_attribute48,
               p_old_pricing_attribute49             => l_pricing_hist_csr.old_pricing_attribute49    ,
               p_new_pricing_attribute49             => l_pricing_hist_csr.new_pricing_attribute49,
               p_old_pricing_attribute50             => l_pricing_hist_csr.old_pricing_attribute50    ,
               p_new_pricing_attribute50             => l_pricing_hist_csr.new_pricing_attribute50,
               p_old_pricing_attribute51             => l_pricing_hist_csr.old_pricing_attribute51    ,
               p_new_pricing_attribute51             => l_pricing_hist_csr.new_pricing_attribute51,
               p_old_pricing_attribute52             => l_pricing_hist_csr.old_pricing_attribute52    ,
               p_new_pricing_attribute52             => l_pricing_hist_csr.new_pricing_attribute52,
               p_old_pricing_attribute53             => l_pricing_hist_csr.old_pricing_attribute53    ,
               p_new_pricing_attribute53             => l_pricing_hist_csr.new_pricing_attribute53,
               p_old_pricing_attribute54             => l_pricing_hist_csr.old_pricing_attribute54    ,
               p_new_pricing_attribute54             => l_pricing_hist_csr.new_pricing_attribute54,
               p_old_pricing_attribute55             => l_pricing_hist_csr.old_pricing_attribute55    ,
               p_new_pricing_attribute55             => l_pricing_hist_csr.new_pricing_attribute55,
               p_old_pricing_attribute56             => l_pricing_hist_csr.old_pricing_attribute56    ,
               p_new_pricing_attribute56             => l_pricing_hist_csr.new_pricing_attribute56,
               p_old_pricing_attribute57             => l_pricing_hist_csr.old_pricing_attribute57    ,
               p_new_pricing_attribute57             => l_pricing_hist_csr.new_pricing_attribute57,
               p_old_pricing_attribute58             => l_pricing_hist_csr.old_pricing_attribute58    ,
               p_new_pricing_attribute58             => l_pricing_hist_csr.new_pricing_attribute58,
               p_old_pricing_attribute59             => l_pricing_hist_csr.old_pricing_attribute59    ,
               p_new_pricing_attribute59             => l_pricing_hist_csr.new_pricing_attribute59,
               p_old_pricing_attribute60             => l_pricing_hist_csr.old_pricing_attribute60    ,
               p_new_pricing_attribute60             => l_pricing_hist_csr.new_pricing_attribute60,
               p_old_pricing_attribute61             => l_pricing_hist_csr.old_pricing_attribute61    ,
               p_new_pricing_attribute61             => l_pricing_hist_csr.new_pricing_attribute61,
               p_old_pricing_attribute62             => l_pricing_hist_csr.old_pricing_attribute62    ,
               p_new_pricing_attribute62             => l_pricing_hist_csr.new_pricing_attribute62,
               p_old_pricing_attribute63             => l_pricing_hist_csr.old_pricing_attribute63    ,
               p_new_pricing_attribute63             => l_pricing_hist_csr.new_pricing_attribute63,
               p_old_pricing_attribute64             => l_pricing_hist_csr.old_pricing_attribute64    ,
               p_new_pricing_attribute64             => l_pricing_hist_csr.new_pricing_attribute64,
               p_old_pricing_attribute65             => l_pricing_hist_csr.old_pricing_attribute65    ,
               p_new_pricing_attribute65             => l_pricing_hist_csr.new_pricing_attribute65,
               p_old_pricing_attribute66             => l_pricing_hist_csr.old_pricing_attribute66    ,
               p_new_pricing_attribute66             => l_pricing_hist_csr.new_pricing_attribute66,
               p_old_pricing_attribute67             => l_pricing_hist_csr.old_pricing_attribute67    ,
               p_new_pricing_attribute67             => l_pricing_hist_csr.new_pricing_attribute67,
               p_old_pricing_attribute68             => l_pricing_hist_csr.old_pricing_attribute68    ,
               p_new_pricing_attribute68             => l_pricing_hist_csr.new_pricing_attribute68,
               p_old_pricing_attribute69             => l_pricing_hist_csr.old_pricing_attribute69    ,
               p_new_pricing_attribute69             => l_pricing_hist_csr.new_pricing_attribute69,
               p_old_pricing_attribute70             => l_pricing_hist_csr.old_pricing_attribute70    ,
               p_new_pricing_attribute70             => l_pricing_hist_csr.new_pricing_attribute70,
               p_old_pricing_attribute71             => l_pricing_hist_csr.old_pricing_attribute71    ,
               p_new_pricing_attribute71             => l_pricing_hist_csr.new_pricing_attribute71,
               p_old_pricing_attribute72             => l_pricing_hist_csr.old_pricing_attribute72    ,
               p_new_pricing_attribute72             => l_pricing_hist_csr.new_pricing_attribute72,
               p_old_pricing_attribute73             => l_pricing_hist_csr.old_pricing_attribute73    ,
               p_new_pricing_attribute73             => l_pricing_hist_csr.new_pricing_attribute73,
               p_old_pricing_attribute74             => l_pricing_hist_csr.old_pricing_attribute74    ,
               p_new_pricing_attribute74             => l_pricing_hist_csr.new_pricing_attribute74,
               p_old_pricing_attribute75             => l_pricing_hist_csr.old_pricing_attribute75    ,
               p_new_pricing_attribute75             => l_pricing_hist_csr.new_pricing_attribute75,
               p_old_pricing_attribute76             => l_pricing_hist_csr.old_pricing_attribute76    ,
               p_new_pricing_attribute76             => l_pricing_hist_csr.new_pricing_attribute76,
               p_old_pricing_attribute77             => l_pricing_hist_csr.old_pricing_attribute77    ,
               p_new_pricing_attribute77             => l_pricing_hist_csr.new_pricing_attribute77,
               p_old_pricing_attribute78             => l_pricing_hist_csr.old_pricing_attribute78    ,
               p_new_pricing_attribute78             => l_pricing_hist_csr.new_pricing_attribute78,
               p_old_pricing_attribute79             => l_pricing_hist_csr.old_pricing_attribute79    ,
               p_new_pricing_attribute79             => l_pricing_hist_csr.new_pricing_attribute79,
               p_old_pricing_attribute80             => l_pricing_hist_csr.old_pricing_attribute80    ,
               p_new_pricing_attribute80             => l_pricing_hist_csr.new_pricing_attribute80,
               p_old_pricing_attribute81             => l_pricing_hist_csr.old_pricing_attribute81    ,
               p_new_pricing_attribute81             => l_pricing_hist_csr.new_pricing_attribute81,
               p_old_pricing_attribute82             => l_pricing_hist_csr.old_pricing_attribute82    ,
               p_new_pricing_attribute82             => l_pricing_hist_csr.new_pricing_attribute82,
               p_old_pricing_attribute83             => l_pricing_hist_csr.old_pricing_attribute83    ,
               p_new_pricing_attribute83             => l_pricing_hist_csr.new_pricing_attribute83,
               p_old_pricing_attribute84             => l_pricing_hist_csr.old_pricing_attribute84    ,
               p_new_pricing_attribute84             => l_pricing_hist_csr.new_pricing_attribute84,
               p_old_pricing_attribute85             => l_pricing_hist_csr.old_pricing_attribute85    ,
               p_new_pricing_attribute85             => l_pricing_hist_csr.new_pricing_attribute85,
               p_old_pricing_attribute86             => l_pricing_hist_csr.old_pricing_attribute86    ,
               p_new_pricing_attribute86             => l_pricing_hist_csr.new_pricing_attribute86,
               p_old_pricing_attribute87             => l_pricing_hist_csr.old_pricing_attribute87    ,
               p_new_pricing_attribute87             => l_pricing_hist_csr.new_pricing_attribute87,
               p_old_pricing_attribute88             => l_pricing_hist_csr.old_pricing_attribute88    ,
               p_new_pricing_attribute88             => l_pricing_hist_csr.new_pricing_attribute88,
               p_old_pricing_attribute89             => l_pricing_hist_csr.old_pricing_attribute89    ,
               p_new_pricing_attribute89             => l_pricing_hist_csr.new_pricing_attribute89,
               p_old_pricing_attribute90             => l_pricing_hist_csr.old_pricing_attribute90    ,
               p_new_pricing_attribute90             => l_pricing_hist_csr.new_pricing_attribute90,
               p_old_pricing_attribute91             => l_pricing_hist_csr.old_pricing_attribute91    ,
               p_new_pricing_attribute91             => l_pricing_hist_csr.new_pricing_attribute91,
               p_old_pricing_attribute92             => l_pricing_hist_csr.old_pricing_attribute92    ,
               p_new_pricing_attribute92             => l_pricing_hist_csr.new_pricing_attribute92,
               p_old_pricing_attribute93             => l_pricing_hist_csr.old_pricing_attribute93    ,
               p_new_pricing_attribute93             => l_pricing_hist_csr.new_pricing_attribute93,
               p_old_pricing_attribute94             => l_pricing_hist_csr.old_pricing_attribute94    ,
               p_new_pricing_attribute94             => l_pricing_hist_csr.new_pricing_attribute94,
               p_old_pricing_attribute95             => l_pricing_hist_csr.old_pricing_attribute95    ,
               p_new_pricing_attribute95             => l_pricing_hist_csr.new_pricing_attribute95,
               p_old_pricing_attribute96             => l_pricing_hist_csr.old_pricing_attribute96    ,
               p_new_pricing_attribute96             => l_pricing_hist_csr.new_pricing_attribute96,
               p_old_pricing_attribute97             => l_pricing_hist_csr.old_pricing_attribute97    ,
               p_new_pricing_attribute97             => l_pricing_hist_csr.new_pricing_attribute97,
               p_old_pricing_attribute98             => l_pricing_hist_csr.old_pricing_attribute98    ,
               p_new_pricing_attribute98             => l_pricing_hist_csr.new_pricing_attribute98,
               p_old_pricing_attribute99             => l_pricing_hist_csr.old_pricing_attribute99    ,
               p_new_pricing_attribute99             => l_pricing_hist_csr.new_pricing_attribute99,
               p_old_pricing_attribute100            => l_pricing_hist_csr.old_pricing_attribute100   ,
               p_new_pricing_attribute100            => l_pricing_hist_csr.new_pricing_attribute100,
               p_old_active_start_date               => l_pricing_hist_csr.old_active_start_date      ,
               p_new_active_start_date               => l_pricing_hist_csr.new_active_start_date  ,
               p_old_active_end_date                 => l_pricing_hist_csr.old_active_end_date        ,
               p_new_active_end_date                 => l_pricing_hist_csr.new_active_end_date    ,
               p_old_context                         => l_pricing_hist_csr.old_context                ,
               p_new_context                         => l_pricing_hist_csr.new_context            ,
               p_old_attribute1                      => l_pricing_hist_csr.old_attribute1             ,
               p_new_attribute1                      => l_pricing_hist_csr.new_attribute1         ,
               p_old_attribute2                      => l_pricing_hist_csr.old_attribute2             ,
               p_new_attribute2                      => l_pricing_hist_csr.new_attribute2         ,
               p_old_attribute3                      => l_pricing_hist_csr.old_attribute3             ,
               p_new_attribute3                      => l_pricing_hist_csr.new_attribute3         ,
               p_old_attribute4                      => l_pricing_hist_csr.old_attribute4             ,
               p_new_attribute4                      => l_pricing_hist_csr.new_attribute4         ,
               p_old_attribute5                      => l_pricing_hist_csr.old_attribute5             ,
               p_new_attribute5                      => l_pricing_hist_csr.new_attribute5         ,
               p_old_attribute6                      => l_pricing_hist_csr.old_attribute6             ,
               p_new_attribute6                      => l_pricing_hist_csr.new_attribute6         ,
               p_old_attribute7                      => l_pricing_hist_csr.old_attribute7             ,
               p_new_attribute7                      => l_pricing_hist_csr.new_attribute7         ,
               p_old_attribute8                      => l_pricing_hist_csr.old_attribute8             ,
               p_new_attribute8                      => l_pricing_hist_csr.new_attribute8         ,
               p_old_attribute9                      => l_pricing_hist_csr.old_attribute9             ,
               p_new_attribute9                      => l_pricing_hist_csr.new_attribute9         ,
               p_old_attribute10                     => l_pricing_hist_csr.old_attribute10            ,
               p_new_attribute10                     => l_pricing_hist_csr.new_attribute10        ,
               p_old_attribute11                     => l_pricing_hist_csr.old_attribute11            ,
               p_new_attribute11                     => l_pricing_hist_csr.new_attribute11        ,
               p_old_attribute12                     => l_pricing_hist_csr.old_attribute12            ,
               p_new_attribute12                     => l_pricing_hist_csr.new_attribute12        ,
               p_old_attribute13                     => l_pricing_hist_csr.old_attribute13            ,
               p_new_attribute13                     => l_pricing_hist_csr.new_attribute13        ,
               p_old_attribute14                     => l_pricing_hist_csr.old_attribute14            ,
               p_new_attribute14                     => l_pricing_hist_csr.new_attribute14        ,
               p_old_attribute15                     => l_pricing_hist_csr.old_attribute15            ,
               p_new_attribute15                     => l_pricing_hist_csr.new_attribute15        ,
               p_full_dump_flag                      => fnd_api.g_miss_char                           ,
               p_created_by                          => fnd_api.g_miss_num, -- fnd_global.user_id,
               p_creation_date                       => fnd_api.g_miss_date                           ,
               p_last_updated_by                     => fnd_global.user_id                            ,
               p_last_update_date                    => sysdate                                       ,
               p_last_update_login                   => fnd_global.user_id                            ,
               p_object_version_number               => fnd_api.g_miss_num                            );

        END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN

       IF (mod(l_pricing_attribs_rec.object_version_number, l_dump_frequency) = 0) THEN

          l_dump_frequency_flag := 'Y';
            -- Grab the input record in a temporary record
          l_temp_pricing_attribs_rec := p_pricing_attribs_rec;
          -- If the mod value is 0 then dump all the columns both changed and unchanged
          -- changed columns have old and new values while the unchanged values have old and new values
          -- exactly same
          IF (p_pricing_attribs_rec.PRICING_CONTEXT = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_CONTEXT := l_pricing_attribs_rec.PRICING_CONTEXT;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE1 := l_pricing_attribs_rec.PRICING_ATTRIBUTE1;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE2 := l_pricing_attribs_rec.PRICING_ATTRIBUTE2;
          END IF;


          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE3 := l_pricing_attribs_rec.PRICING_ATTRIBUTE3;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
               l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE4 := l_pricing_attribs_rec.PRICING_ATTRIBUTE4;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE5 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE5 := l_pricing_attribs_rec.PRICING_ATTRIBUTE5;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE6 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE6 := l_pricing_attribs_rec.PRICING_ATTRIBUTE6;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE7 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE7 := l_pricing_attribs_rec.PRICING_ATTRIBUTE7;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE8 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE8 := l_pricing_attribs_rec.PRICING_ATTRIBUTE8;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE9 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE9 := l_pricing_attribs_rec.PRICING_ATTRIBUTE9;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE10 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE10 := l_pricing_attribs_rec.PRICING_ATTRIBUTE10;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE11 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE11 := l_pricing_attribs_rec.PRICING_ATTRIBUTE11;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE12 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE12 := l_pricing_attribs_rec.PRICING_ATTRIBUTE12;
          END IF;


          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE13 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE13 := l_pricing_attribs_rec.PRICING_ATTRIBUTE13;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE14 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE14 := l_pricing_attribs_rec.PRICING_ATTRIBUTE14;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE15 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE15 := l_pricing_attribs_rec.PRICING_ATTRIBUTE15;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE16 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE16 := l_pricing_attribs_rec.PRICING_ATTRIBUTE16;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE17 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE17 := l_pricing_attribs_rec.PRICING_ATTRIBUTE17;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE18 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE18 := l_pricing_attribs_rec.PRICING_ATTRIBUTE18;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE19 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE19 := l_pricing_attribs_rec.PRICING_ATTRIBUTE19;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE20 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE20 := l_pricing_attribs_rec.PRICING_ATTRIBUTE20;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE21 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE21 := l_pricing_attribs_rec.PRICING_ATTRIBUTE21;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE22 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE22 := l_pricing_attribs_rec.PRICING_ATTRIBUTE22;
          END IF;


          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE23 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE23 := l_pricing_attribs_rec.PRICING_ATTRIBUTE23;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE24 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE24 := l_pricing_attribs_rec.PRICING_ATTRIBUTE24;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE25 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE25 := l_pricing_attribs_rec.PRICING_ATTRIBUTE25;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE26 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE26 := l_pricing_attribs_rec.PRICING_ATTRIBUTE26;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE27 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE27 := l_pricing_attribs_rec.PRICING_ATTRIBUTE27;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE28 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE28 := l_pricing_attribs_rec.PRICING_ATTRIBUTE28;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE29 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE29 := l_pricing_attribs_rec.PRICING_ATTRIBUTE29;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE30 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE30 := l_pricing_attribs_rec.PRICING_ATTRIBUTE30;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE31 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE31 := l_pricing_attribs_rec.PRICING_ATTRIBUTE31;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE32 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE32 := l_pricing_attribs_rec.PRICING_ATTRIBUTE32;
          END IF;


          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE33 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE33 := l_pricing_attribs_rec.PRICING_ATTRIBUTE33;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE34 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE34 := l_pricing_attribs_rec.PRICING_ATTRIBUTE34;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE35 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE35 := l_pricing_attribs_rec.PRICING_ATTRIBUTE35;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE36 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE36 := l_pricing_attribs_rec.PRICING_ATTRIBUTE36;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE37 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE37 := l_pricing_attribs_rec.PRICING_ATTRIBUTE37;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE38 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE38 := l_pricing_attribs_rec.PRICING_ATTRIBUTE38;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE39 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE39 := l_pricing_attribs_rec.PRICING_ATTRIBUTE39;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE40 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE40 := l_pricing_attribs_rec.PRICING_ATTRIBUTE40;
          END IF;


          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE41 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE41 := l_pricing_attribs_rec.PRICING_ATTRIBUTE41;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE42 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE42 := l_pricing_attribs_rec.PRICING_ATTRIBUTE42;
          END IF;


          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE43 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE43 := l_pricing_attribs_rec.PRICING_ATTRIBUTE43;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE44 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE44 := l_pricing_attribs_rec.PRICING_ATTRIBUTE44;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE45 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE45 := l_pricing_attribs_rec.PRICING_ATTRIBUTE45;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE46 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE46 := l_pricing_attribs_rec.PRICING_ATTRIBUTE46;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE47 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE47 := l_pricing_attribs_rec.PRICING_ATTRIBUTE47;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE48 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE48 := l_pricing_attribs_rec.PRICING_ATTRIBUTE48;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE49 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE49 := l_pricing_attribs_rec.PRICING_ATTRIBUTE49;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE50 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE50 := l_pricing_attribs_rec.PRICING_ATTRIBUTE50;
          END IF;


          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE51 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE51 := l_pricing_attribs_rec.PRICING_ATTRIBUTE51;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE52 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE52 := l_pricing_attribs_rec.PRICING_ATTRIBUTE52;
          END IF;


          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE53 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE53 := l_pricing_attribs_rec.PRICING_ATTRIBUTE53;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE54 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE54 := l_pricing_attribs_rec.PRICING_ATTRIBUTE54;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE55 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE55 := l_pricing_attribs_rec.PRICING_ATTRIBUTE55;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE56 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE56 := l_pricing_attribs_rec.PRICING_ATTRIBUTE56;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE57 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE57 := l_pricing_attribs_rec.PRICING_ATTRIBUTE57;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE58 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE58 := l_pricing_attribs_rec.PRICING_ATTRIBUTE58;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE59 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE59 := l_pricing_attribs_rec.PRICING_ATTRIBUTE59;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE60 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE60 := l_pricing_attribs_rec.PRICING_ATTRIBUTE60;
          END IF;


          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE61 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE61 := l_pricing_attribs_rec.PRICING_ATTRIBUTE61;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE62 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE62 := l_pricing_attribs_rec.PRICING_ATTRIBUTE62;
          END IF;


          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE63 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE63 := l_pricing_attribs_rec.PRICING_ATTRIBUTE63;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE64 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE64 := l_pricing_attribs_rec.PRICING_ATTRIBUTE64;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE65 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE65 := l_pricing_attribs_rec.PRICING_ATTRIBUTE65;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE66 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE66 := l_pricing_attribs_rec.PRICING_ATTRIBUTE66;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE67 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE67 := l_pricing_attribs_rec.PRICING_ATTRIBUTE67;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE68 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE68 := l_pricing_attribs_rec.PRICING_ATTRIBUTE68;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE69 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE69 := l_pricing_attribs_rec.PRICING_ATTRIBUTE69;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE70 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE70 := l_pricing_attribs_rec.PRICING_ATTRIBUTE70;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE71 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE71 := l_pricing_attribs_rec.PRICING_ATTRIBUTE71;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE72 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE72 := l_pricing_attribs_rec.PRICING_ATTRIBUTE72;
          END IF;


          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE73 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE73 := l_pricing_attribs_rec.PRICING_ATTRIBUTE73;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE74 = FND_API.G_MISS_CHAR) THEN
               l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE74 := l_pricing_attribs_rec.PRICING_ATTRIBUTE74;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE75 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE75 := l_pricing_attribs_rec.PRICING_ATTRIBUTE75;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE76 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE76 := l_pricing_attribs_rec.PRICING_ATTRIBUTE76;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE77 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE77 := l_pricing_attribs_rec.PRICING_ATTRIBUTE77;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE78 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE78 := l_pricing_attribs_rec.PRICING_ATTRIBUTE78;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE79 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE79 := l_pricing_attribs_rec.PRICING_ATTRIBUTE79;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE80 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE80 := l_pricing_attribs_rec.PRICING_ATTRIBUTE80;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE81 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE81 := l_pricing_attribs_rec.PRICING_ATTRIBUTE81;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE82 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE82 := l_pricing_attribs_rec.PRICING_ATTRIBUTE82;
          END IF;


          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE83 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE83 := l_pricing_attribs_rec.PRICING_ATTRIBUTE83;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE84 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE84 := l_pricing_attribs_rec.PRICING_ATTRIBUTE84;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE85 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE85 := l_pricing_attribs_rec.PRICING_ATTRIBUTE85;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE86 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE86 := l_pricing_attribs_rec.PRICING_ATTRIBUTE86;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE87 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE87 := l_pricing_attribs_rec.PRICING_ATTRIBUTE87;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE88 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE88 := l_pricing_attribs_rec.PRICING_ATTRIBUTE88;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE89 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE89 := l_pricing_attribs_rec.PRICING_ATTRIBUTE89;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE90 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE90 := l_pricing_attribs_rec.PRICING_ATTRIBUTE90;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE91 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE91 := l_pricing_attribs_rec.PRICING_ATTRIBUTE91;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE92 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE92 := l_pricing_attribs_rec.PRICING_ATTRIBUTE92;
          END IF;


          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE93 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE93 := l_pricing_attribs_rec.PRICING_ATTRIBUTE93;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE94 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE94 := l_pricing_attribs_rec.PRICING_ATTRIBUTE94;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE95 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE95 := l_pricing_attribs_rec.PRICING_ATTRIBUTE95;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE96 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE96 := l_pricing_attribs_rec.PRICING_ATTRIBUTE96;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE97 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE97 := l_pricing_attribs_rec.PRICING_ATTRIBUTE97;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE98 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE98 := l_pricing_attribs_rec.PRICING_ATTRIBUTE98;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE99 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE99 := l_pricing_attribs_rec.PRICING_ATTRIBUTE99;
          END IF;

          IF (p_pricing_attribs_rec.PRICING_ATTRIBUTE100 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.PRICING_ATTRIBUTE100 := l_pricing_attribs_rec.PRICING_ATTRIBUTE100;
          END IF;

          IF (p_pricing_attribs_rec.ACTIVE_START_DATE = FND_API.G_MISS_DATE) THEN
                l_temp_pricing_attribs_rec.ACTIVE_START_DATE := l_pricing_attribs_rec.ACTIVE_START_DATE;
          END IF;

          IF (p_pricing_attribs_rec.ACTIVE_END_DATE = FND_API.G_MISS_DATE) THEN
                l_temp_pricing_attribs_rec.ACTIVE_END_DATE := l_pricing_attribs_rec.ACTIVE_END_DATE;
          END IF;

          IF (p_pricing_attribs_rec.CONTEXT = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.CONTEXT := l_pricing_attribs_rec.CONTEXT;
          END IF;

          IF (p_pricing_attribs_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE1 := l_pricing_attribs_rec.ATTRIBUTE1;
          END IF;
          IF (p_pricing_attribs_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE2 := l_pricing_attribs_rec.ATTRIBUTE2;
          END IF;
          IF (p_pricing_attribs_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE3 := l_pricing_attribs_rec.ATTRIBUTE3;
          END IF;
          IF (p_pricing_attribs_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE4 := l_pricing_attribs_rec.ATTRIBUTE4;
          END IF;
          IF (p_pricing_attribs_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE5 := l_pricing_attribs_rec.ATTRIBUTE5;
          END IF;
          IF (p_pricing_attribs_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE6 := l_pricing_attribs_rec.ATTRIBUTE6;
          END IF;
          IF (p_pricing_attribs_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE7 := l_pricing_attribs_rec.ATTRIBUTE7;
          END IF;
          IF (p_pricing_attribs_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE8 := l_pricing_attribs_rec.ATTRIBUTE8;
          END IF;
          IF (p_pricing_attribs_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE9 := l_pricing_attribs_rec.ATTRIBUTE9;
          END IF;
          IF (p_pricing_attribs_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE10 := l_pricing_attribs_rec.ATTRIBUTE10;
          END IF;
          IF (p_pricing_attribs_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE11 := l_pricing_attribs_rec.ATTRIBUTE11;
          END IF;
          IF (p_pricing_attribs_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE12 := l_pricing_attribs_rec.ATTRIBUTE12;
          END IF;
          IF (p_pricing_attribs_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE13 := l_pricing_attribs_rec.ATTRIBUTE13;
          END IF;
          IF (p_pricing_attribs_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE14 := l_pricing_attribs_rec.ATTRIBUTE14;
          END IF;
          IF (p_pricing_attribs_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR) THEN
                l_temp_pricing_attribs_rec.ATTRIBUTE15 := l_pricing_attribs_rec.ATTRIBUTE15;
          END IF;

          -- Create a history
          CSI_I_PRICING_ATTRIBS_H_PKG.Insert_Row(
               px_PRICE_ATTRIB_HISTORY_ID            => l_pricing_attrib_h_id,
               p_PRICING_ATTRIBUTE_ID                => l_pricing_attrib_id,
               p_TRANSACTION_ID                      => p_txn_rec.transaction_id,
               p_OLD_PRICING_CONTEXT                 => l_pricing_attribs_rec.pricing_context,
               p_NEW_PRICING_CONTEXT                 => l_temp_pricing_attribs_rec.pricing_context,
               p_OLD_PRICING_ATTRIBUTE1              => l_pricing_attribs_rec.pricing_attribute1,
               p_NEW_PRICING_ATTRIBUTE1              => l_temp_pricing_attribs_rec.pricing_attribute1,
               p_OLD_PRICING_ATTRIBUTE2              => l_pricing_attribs_rec.pricing_attribute2,
               p_NEW_PRICING_ATTRIBUTE2              => l_temp_pricing_attribs_rec.pricing_attribute2,
               p_OLD_PRICING_ATTRIBUTE3              => l_pricing_attribs_rec.pricing_attribute3,
               p_NEW_PRICING_ATTRIBUTE3              => l_temp_pricing_attribs_rec.pricing_attribute3,
               p_OLD_PRICING_ATTRIBUTE4              => l_pricing_attribs_rec.pricing_attribute4,
               p_NEW_PRICING_ATTRIBUTE4              => l_temp_pricing_attribs_rec.pricing_attribute4,
               p_OLD_PRICING_ATTRIBUTE5              => l_pricing_attribs_rec.pricing_attribute5,
               p_NEW_PRICING_ATTRIBUTE5              => l_temp_pricing_attribs_rec.pricing_attribute5,
               p_OLD_PRICING_ATTRIBUTE6              => l_pricing_attribs_rec.pricing_attribute6,
               p_NEW_PRICING_ATTRIBUTE6              => l_temp_pricing_attribs_rec.pricing_attribute6,
               p_OLD_PRICING_ATTRIBUTE7              => l_pricing_attribs_rec.pricing_attribute7,
               p_NEW_PRICING_ATTRIBUTE7              => l_temp_pricing_attribs_rec.pricing_attribute7,
               p_OLD_PRICING_ATTRIBUTE8              => l_pricing_attribs_rec.pricing_attribute8,
               p_NEW_PRICING_ATTRIBUTE8              => l_temp_pricing_attribs_rec.pricing_attribute8,
               p_OLD_PRICING_ATTRIBUTE9              => l_pricing_attribs_rec.pricing_attribute9,
               p_NEW_PRICING_ATTRIBUTE9              => l_temp_pricing_attribs_rec.pricing_attribute9,
               p_OLD_PRICING_ATTRIBUTE10             => l_pricing_attribs_rec.pricing_attribute10,
               p_NEW_PRICING_ATTRIBUTE10             => l_temp_pricing_attribs_rec.pricing_attribute10,
               p_OLD_PRICING_ATTRIBUTE11             => l_pricing_attribs_rec.pricing_attribute11,
               p_NEW_PRICING_ATTRIBUTE11             => l_temp_pricing_attribs_rec.pricing_attribute11,
               p_OLD_PRICING_ATTRIBUTE12             => l_pricing_attribs_rec.pricing_attribute12,
               p_NEW_PRICING_ATTRIBUTE12             => l_temp_pricing_attribs_rec.pricing_attribute12,
               p_OLD_PRICING_ATTRIBUTE13             => l_pricing_attribs_rec.pricing_attribute13,
               p_NEW_PRICING_ATTRIBUTE13             => l_temp_pricing_attribs_rec.pricing_attribute13,
               p_OLD_PRICING_ATTRIBUTE14             => l_pricing_attribs_rec.pricing_attribute14,
               p_NEW_PRICING_ATTRIBUTE14             => l_temp_pricing_attribs_rec.pricing_attribute14,
               p_OLD_PRICING_ATTRIBUTE15             => l_pricing_attribs_rec.pricing_attribute15,
               p_NEW_PRICING_ATTRIBUTE15             => l_temp_pricing_attribs_rec.pricing_attribute15,
               p_OLD_PRICING_ATTRIBUTE16             => l_pricing_attribs_rec.pricing_attribute16,
               p_NEW_PRICING_ATTRIBUTE16             => l_temp_pricing_attribs_rec.pricing_attribute16,
               p_OLD_PRICING_ATTRIBUTE17             => l_pricing_attribs_rec.pricing_attribute17,
               p_NEW_PRICING_ATTRIBUTE17             => l_temp_pricing_attribs_rec.pricing_attribute17,
               p_OLD_PRICING_ATTRIBUTE18             => l_pricing_attribs_rec.pricing_attribute18,
               p_NEW_PRICING_ATTRIBUTE18             => l_temp_pricing_attribs_rec.pricing_attribute18,
               p_OLD_PRICING_ATTRIBUTE19             => l_pricing_attribs_rec.pricing_attribute19,
               p_NEW_PRICING_ATTRIBUTE19             => l_temp_pricing_attribs_rec.pricing_attribute19,
               p_OLD_PRICING_ATTRIBUTE20             => l_pricing_attribs_rec.pricing_attribute20,
               p_NEW_PRICING_ATTRIBUTE20             => l_temp_pricing_attribs_rec.pricing_attribute20,
               p_OLD_PRICING_ATTRIBUTE21             => l_pricing_attribs_rec.pricing_attribute21,
               p_NEW_PRICING_ATTRIBUTE21             => l_temp_pricing_attribs_rec.pricing_attribute21,
               p_OLD_PRICING_ATTRIBUTE22             => l_pricing_attribs_rec.pricing_attribute22,
               p_NEW_PRICING_ATTRIBUTE22             => l_temp_pricing_attribs_rec.pricing_attribute22,
               p_OLD_PRICING_ATTRIBUTE23             => l_pricing_attribs_rec.pricing_attribute23,
               p_NEW_PRICING_ATTRIBUTE23             => l_temp_pricing_attribs_rec.pricing_attribute23,
               p_OLD_PRICING_ATTRIBUTE24             => l_pricing_attribs_rec.pricing_attribute24,
               p_NEW_PRICING_ATTRIBUTE24             => l_temp_pricing_attribs_rec.pricing_attribute24,
               p_NEW_PRICING_ATTRIBUTE25             => l_pricing_attribs_rec.pricing_attribute25,
               p_OLD_PRICING_ATTRIBUTE25             => l_temp_pricing_attribs_rec.pricing_attribute25,
               p_OLD_PRICING_ATTRIBUTE26             => l_pricing_attribs_rec.pricing_attribute26,
               p_NEW_PRICING_ATTRIBUTE26             => l_temp_pricing_attribs_rec.pricing_attribute26,
               p_OLD_PRICING_ATTRIBUTE27             => l_pricing_attribs_rec.pricing_attribute27,
               p_NEW_PRICING_ATTRIBUTE27             => l_temp_pricing_attribs_rec.pricing_attribute27,
               p_OLD_PRICING_ATTRIBUTE28             => l_pricing_attribs_rec.pricing_attribute28,
               p_NEW_PRICING_ATTRIBUTE28             => l_temp_pricing_attribs_rec.pricing_attribute28,
               p_OLD_PRICING_ATTRIBUTE29             => l_pricing_attribs_rec.pricing_attribute29,
               p_NEW_PRICING_ATTRIBUTE29             => l_temp_pricing_attribs_rec.pricing_attribute29,
               p_OLD_PRICING_ATTRIBUTE30             => l_pricing_attribs_rec.pricing_attribute30,
               p_NEW_PRICING_ATTRIBUTE30             => l_temp_pricing_attribs_rec.pricing_attribute30,
               p_OLD_PRICING_ATTRIBUTE31             => l_pricing_attribs_rec.pricing_attribute31,
               p_NEW_PRICING_ATTRIBUTE31             => l_temp_pricing_attribs_rec.pricing_attribute31,
               p_OLD_PRICING_ATTRIBUTE32             => l_pricing_attribs_rec.pricing_attribute32,
               p_NEW_PRICING_ATTRIBUTE32             => l_temp_pricing_attribs_rec.pricing_attribute32,
               p_OLD_PRICING_ATTRIBUTE33             => l_pricing_attribs_rec.pricing_attribute33,
               p_NEW_PRICING_ATTRIBUTE33             => l_temp_pricing_attribs_rec.pricing_attribute33,
               p_OLD_PRICING_ATTRIBUTE34             => l_pricing_attribs_rec.pricing_attribute34,
               p_NEW_PRICING_ATTRIBUTE34             => l_temp_pricing_attribs_rec.pricing_attribute34,
               p_OLD_PRICING_ATTRIBUTE35             => l_pricing_attribs_rec.pricing_attribute35,
               p_NEW_PRICING_ATTRIBUTE35             => l_temp_pricing_attribs_rec.pricing_attribute35,
               p_OLD_PRICING_ATTRIBUTE36             => l_pricing_attribs_rec.pricing_attribute36,
               p_NEW_PRICING_ATTRIBUTE36             => l_temp_pricing_attribs_rec.pricing_attribute36,
               p_OLD_PRICING_ATTRIBUTE37             => l_pricing_attribs_rec.pricing_attribute37,
               p_NEW_PRICING_ATTRIBUTE37             => l_temp_pricing_attribs_rec.pricing_attribute37,
               p_OLD_PRICING_ATTRIBUTE38             => l_pricing_attribs_rec.pricing_attribute38,
               p_NEW_PRICING_ATTRIBUTE38             => l_temp_pricing_attribs_rec.pricing_attribute38,
               p_OLD_PRICING_ATTRIBUTE39             => l_pricing_attribs_rec.pricing_attribute39,
               p_NEW_PRICING_ATTRIBUTE39             => l_temp_pricing_attribs_rec.pricing_attribute39,
               p_OLD_PRICING_ATTRIBUTE40             => l_pricing_attribs_rec.pricing_attribute40,
               p_NEW_PRICING_ATTRIBUTE40             => l_temp_pricing_attribs_rec.pricing_attribute40,
               p_OLD_PRICING_ATTRIBUTE41             => l_pricing_attribs_rec.pricing_attribute41,
               p_NEW_PRICING_ATTRIBUTE41             => l_temp_pricing_attribs_rec.pricing_attribute41,
               p_OLD_PRICING_ATTRIBUTE42             => l_pricing_attribs_rec.pricing_attribute42,
               p_NEW_PRICING_ATTRIBUTE42             => l_temp_pricing_attribs_rec.pricing_attribute42,
               p_OLD_PRICING_ATTRIBUTE43             => l_pricing_attribs_rec.pricing_attribute43,
               p_NEW_PRICING_ATTRIBUTE43             => l_temp_pricing_attribs_rec.pricing_attribute43,
               p_OLD_PRICING_ATTRIBUTE44             => l_pricing_attribs_rec.pricing_attribute44,
               p_NEW_PRICING_ATTRIBUTE44             => l_temp_pricing_attribs_rec.pricing_attribute44,
               p_OLD_PRICING_ATTRIBUTE45             => l_pricing_attribs_rec.pricing_attribute45,
               p_NEW_PRICING_ATTRIBUTE45             => l_temp_pricing_attribs_rec.pricing_attribute45,
               p_OLD_PRICING_ATTRIBUTE46             => l_pricing_attribs_rec.pricing_attribute46,
               p_NEW_PRICING_ATTRIBUTE46             => l_temp_pricing_attribs_rec.pricing_attribute46,
               p_OLD_PRICING_ATTRIBUTE47             => l_pricing_attribs_rec.pricing_attribute47,
               p_NEW_PRICING_ATTRIBUTE47             => l_temp_pricing_attribs_rec.pricing_attribute47,
               p_OLD_PRICING_ATTRIBUTE48             => l_pricing_attribs_rec.pricing_attribute48,
               p_NEW_PRICING_ATTRIBUTE48             => l_temp_pricing_attribs_rec.pricing_attribute48,
               p_OLD_PRICING_ATTRIBUTE49             => l_pricing_attribs_rec.pricing_attribute49,
               p_NEW_PRICING_ATTRIBUTE49             => l_temp_pricing_attribs_rec.pricing_attribute49,
               p_OLD_PRICING_ATTRIBUTE50             => l_pricing_attribs_rec.pricing_attribute50,
               p_NEW_PRICING_ATTRIBUTE50             => l_temp_pricing_attribs_rec.pricing_attribute50,
               p_OLD_PRICING_ATTRIBUTE51             =>  l_pricing_attribs_rec.pricing_attribute51,
               p_NEW_PRICING_ATTRIBUTE51             => l_temp_pricing_attribs_rec.pricing_attribute51,
               p_OLD_PRICING_ATTRIBUTE52             => l_pricing_attribs_rec.pricing_attribute52,
               p_NEW_PRICING_ATTRIBUTE52             => l_temp_pricing_attribs_rec.pricing_attribute52,
               p_OLD_PRICING_ATTRIBUTE53             => l_pricing_attribs_rec.pricing_attribute53,
               p_NEW_PRICING_ATTRIBUTE53             => l_temp_pricing_attribs_rec.pricing_attribute53,
               p_OLD_PRICING_ATTRIBUTE54             => l_pricing_attribs_rec.pricing_attribute54,
               p_NEW_PRICING_ATTRIBUTE54             => l_temp_pricing_attribs_rec.pricing_attribute54,
               p_OLD_PRICING_ATTRIBUTE55             => l_pricing_attribs_rec.pricing_attribute55,
               p_NEW_PRICING_ATTRIBUTE55             => l_temp_pricing_attribs_rec.pricing_attribute55,
               p_OLD_PRICING_ATTRIBUTE56             => l_pricing_attribs_rec.pricing_attribute56,
               p_NEW_PRICING_ATTRIBUTE56             => l_temp_pricing_attribs_rec.pricing_attribute56,
               p_OLD_PRICING_ATTRIBUTE57             => l_pricing_attribs_rec.pricing_attribute57,
               p_NEW_PRICING_ATTRIBUTE57             => l_temp_pricing_attribs_rec.pricing_attribute57,
               p_OLD_PRICING_ATTRIBUTE58             => l_pricing_attribs_rec.pricing_attribute58,
               p_NEW_PRICING_ATTRIBUTE58             => l_temp_pricing_attribs_rec.pricing_attribute58,
               p_OLD_PRICING_ATTRIBUTE59             => l_pricing_attribs_rec.pricing_attribute59,
               p_NEW_PRICING_ATTRIBUTE59             => l_temp_pricing_attribs_rec.pricing_attribute59,
               p_OLD_PRICING_ATTRIBUTE60             => l_pricing_attribs_rec.pricing_attribute60,
               p_NEW_PRICING_ATTRIBUTE60             => l_temp_pricing_attribs_rec.pricing_attribute60,
               p_OLD_PRICING_ATTRIBUTE61             => l_pricing_attribs_rec.pricing_attribute61,
               p_NEW_PRICING_ATTRIBUTE61             => l_temp_pricing_attribs_rec.pricing_attribute61,
               p_OLD_PRICING_ATTRIBUTE62             => l_pricing_attribs_rec.pricing_attribute62,
               p_NEW_PRICING_ATTRIBUTE62             => l_temp_pricing_attribs_rec.pricing_attribute62,
               p_OLD_PRICING_ATTRIBUTE63             => l_pricing_attribs_rec.pricing_attribute63,
               p_NEW_PRICING_ATTRIBUTE63             => l_temp_pricing_attribs_rec.pricing_attribute63,
               p_OLD_PRICING_ATTRIBUTE64             => l_pricing_attribs_rec.pricing_attribute64,
               p_NEW_PRICING_ATTRIBUTE64             => l_temp_pricing_attribs_rec.pricing_attribute64,
               p_OLD_PRICING_ATTRIBUTE65             => l_pricing_attribs_rec.pricing_attribute65,
               p_NEW_PRICING_ATTRIBUTE65             => l_temp_pricing_attribs_rec.pricing_attribute65,
               p_OLD_PRICING_ATTRIBUTE66             => l_pricing_attribs_rec.pricing_attribute66,
               p_NEW_PRICING_ATTRIBUTE66             => l_temp_pricing_attribs_rec.pricing_attribute66,
               p_OLD_PRICING_ATTRIBUTE67             => l_pricing_attribs_rec.pricing_attribute67,
               p_NEW_PRICING_ATTRIBUTE67             => l_temp_pricing_attribs_rec.pricing_attribute67,
               p_OLD_PRICING_ATTRIBUTE68             => l_pricing_attribs_rec.pricing_attribute68,
               p_NEW_PRICING_ATTRIBUTE68             => l_temp_pricing_attribs_rec.pricing_attribute68,
               p_OLD_PRICING_ATTRIBUTE69             => l_pricing_attribs_rec.pricing_attribute69,
               p_NEW_PRICING_ATTRIBUTE69             => l_temp_pricing_attribs_rec.pricing_attribute69,
               p_OLD_PRICING_ATTRIBUTE70             => l_pricing_attribs_rec.pricing_attribute70,
               p_NEW_PRICING_ATTRIBUTE70             => l_temp_pricing_attribs_rec.pricing_attribute70,
               p_OLD_PRICING_ATTRIBUTE71             => l_pricing_attribs_rec.pricing_attribute71,
               p_NEW_PRICING_ATTRIBUTE71             => l_temp_pricing_attribs_rec.pricing_attribute71,
               p_OLD_PRICING_ATTRIBUTE72             => l_pricing_attribs_rec.pricing_attribute72,
               p_NEW_PRICING_ATTRIBUTE72             => l_temp_pricing_attribs_rec.pricing_attribute72,
               p_OLD_PRICING_ATTRIBUTE73             => l_pricing_attribs_rec.pricing_attribute73,
               p_NEW_PRICING_ATTRIBUTE73             => l_temp_pricing_attribs_rec.pricing_attribute73,
               p_OLD_PRICING_ATTRIBUTE74             => l_pricing_attribs_rec.pricing_attribute74,
               p_NEW_PRICING_ATTRIBUTE74             => l_temp_pricing_attribs_rec.pricing_attribute74,
               p_OLD_PRICING_ATTRIBUTE75             => l_pricing_attribs_rec.pricing_attribute75,
               p_NEW_PRICING_ATTRIBUTE75             => l_temp_pricing_attribs_rec.pricing_attribute75,
               p_OLD_PRICING_ATTRIBUTE76             => l_pricing_attribs_rec.pricing_attribute76,
               p_NEW_PRICING_ATTRIBUTE76             => l_temp_pricing_attribs_rec.pricing_attribute76,
               p_OLD_PRICING_ATTRIBUTE77             => l_pricing_attribs_rec.pricing_attribute77,
               p_NEW_PRICING_ATTRIBUTE77             => l_temp_pricing_attribs_rec.pricing_attribute77,
               p_OLD_PRICING_ATTRIBUTE78             => l_pricing_attribs_rec.pricing_attribute78,
               p_NEW_PRICING_ATTRIBUTE78             => l_temp_pricing_attribs_rec.pricing_attribute78,
               p_OLD_PRICING_ATTRIBUTE79             => l_pricing_attribs_rec.pricing_attribute79,
               p_NEW_PRICING_ATTRIBUTE79             => l_temp_pricing_attribs_rec.pricing_attribute79,
               p_OLD_PRICING_ATTRIBUTE80             => l_pricing_attribs_rec.pricing_attribute80,
               p_NEW_PRICING_ATTRIBUTE80             => l_temp_pricing_attribs_rec.pricing_attribute80,
               p_OLD_PRICING_ATTRIBUTE81             => l_pricing_attribs_rec.pricing_attribute81,
               p_NEW_PRICING_ATTRIBUTE81             => l_temp_pricing_attribs_rec.pricing_attribute81,
               p_OLD_PRICING_ATTRIBUTE82             => l_pricing_attribs_rec.pricing_attribute82,
               p_NEW_PRICING_ATTRIBUTE82             => l_temp_pricing_attribs_rec.pricing_attribute82,
               p_OLD_PRICING_ATTRIBUTE83             => l_pricing_attribs_rec.pricing_attribute83,
               p_NEW_PRICING_ATTRIBUTE83             => l_temp_pricing_attribs_rec.pricing_attribute83,
               p_OLD_PRICING_ATTRIBUTE84             => l_pricing_attribs_rec.pricing_attribute84,
               p_NEW_PRICING_ATTRIBUTE84             => l_temp_pricing_attribs_rec.pricing_attribute84,
               p_OLD_PRICING_ATTRIBUTE85             => l_pricing_attribs_rec.pricing_attribute85,
               p_NEW_PRICING_ATTRIBUTE85             => l_temp_pricing_attribs_rec.pricing_attribute85,
               p_OLD_PRICING_ATTRIBUTE86             => l_pricing_attribs_rec.pricing_attribute86,
               p_NEW_PRICING_ATTRIBUTE86             => l_temp_pricing_attribs_rec.pricing_attribute86,
               p_OLD_PRICING_ATTRIBUTE87             => l_pricing_attribs_rec.pricing_attribute87,
               p_NEW_PRICING_ATTRIBUTE87             => l_temp_pricing_attribs_rec.pricing_attribute87,
               p_OLD_PRICING_ATTRIBUTE88             => l_pricing_attribs_rec.pricing_attribute88,
               p_NEW_PRICING_ATTRIBUTE88             => l_temp_pricing_attribs_rec.pricing_attribute88,
               p_OLD_PRICING_ATTRIBUTE89             => l_pricing_attribs_rec.pricing_attribute89,
               p_NEW_PRICING_ATTRIBUTE89             => l_temp_pricing_attribs_rec.pricing_attribute89,
               p_OLD_PRICING_ATTRIBUTE90             => l_pricing_attribs_rec.pricing_attribute90,
               p_NEW_PRICING_ATTRIBUTE90             => l_temp_pricing_attribs_rec.pricing_attribute90,
               p_OLD_PRICING_ATTRIBUTE91             => l_pricing_attribs_rec.pricing_attribute91,
               p_NEW_PRICING_ATTRIBUTE91             => l_temp_pricing_attribs_rec.pricing_attribute91,
               p_OLD_PRICING_ATTRIBUTE92             => l_pricing_attribs_rec.pricing_attribute92,
               p_NEW_PRICING_ATTRIBUTE92             => l_temp_pricing_attribs_rec.pricing_attribute92,
               p_OLD_PRICING_ATTRIBUTE93             => l_pricing_attribs_rec.pricing_attribute93,
               p_NEW_PRICING_ATTRIBUTE93             => l_temp_pricing_attribs_rec.pricing_attribute93,
               p_OLD_PRICING_ATTRIBUTE94             => l_pricing_attribs_rec.pricing_attribute94,
               p_NEW_PRICING_ATTRIBUTE94             => l_temp_pricing_attribs_rec.pricing_attribute94,
               p_OLD_PRICING_ATTRIBUTE95             => l_pricing_attribs_rec.pricing_attribute95,
               p_NEW_PRICING_ATTRIBUTE95             => l_temp_pricing_attribs_rec.pricing_attribute95,
               p_OLD_PRICING_ATTRIBUTE96             => l_pricing_attribs_rec.pricing_attribute96,
               p_NEW_PRICING_ATTRIBUTE96             => l_temp_pricing_attribs_rec.pricing_attribute96,
               p_OLD_PRICING_ATTRIBUTE97             => l_pricing_attribs_rec.pricing_attribute97,
               p_NEW_PRICING_ATTRIBUTE97             => l_temp_pricing_attribs_rec.pricing_attribute97,
               p_OLD_PRICING_ATTRIBUTE98             => l_pricing_attribs_rec.pricing_attribute98,
               p_NEW_PRICING_ATTRIBUTE98             => l_temp_pricing_attribs_rec.pricing_attribute98,
               p_OLD_PRICING_ATTRIBUTE99             => l_pricing_attribs_rec.pricing_attribute99,
               p_NEW_PRICING_ATTRIBUTE99             => l_temp_pricing_attribs_rec.pricing_attribute99,
               p_OLD_PRICING_ATTRIBUTE100            => l_pricing_attribs_rec.pricing_attribute100,
               p_NEW_PRICING_ATTRIBUTE100            => l_temp_pricing_attribs_rec.pricing_attribute100,
               p_OLD_ACTIVE_START_DATE               => l_pricing_attribs_rec.active_start_date,
               p_NEW_ACTIVE_START_DATE               => l_temp_pricing_attribs_rec.active_start_date,
               p_OLD_ACTIVE_END_DATE                 => l_pricing_attribs_rec.active_end_date,
               p_NEW_ACTIVE_END_DATE                 => l_temp_pricing_attribs_rec.active_end_date,
               p_OLD_CONTEXT                         => l_pricing_attribs_rec.context          ,
               p_NEW_CONTEXT                         => l_temp_pricing_attribs_rec.context               ,
               p_OLD_ATTRIBUTE1                      => l_pricing_attribs_rec.ATTRIBUTE1       ,
               p_NEW_ATTRIBUTE1                      => l_temp_pricing_attribs_rec.ATTRIBUTE1            ,
               p_OLD_ATTRIBUTE2                      => l_pricing_attribs_rec.ATTRIBUTE2       ,
               p_NEW_ATTRIBUTE2                      => l_temp_pricing_attribs_rec.ATTRIBUTE2            ,
               p_OLD_ATTRIBUTE3                      => l_pricing_attribs_rec.ATTRIBUTE3       ,
               p_NEW_ATTRIBUTE3                      => l_temp_pricing_attribs_rec.ATTRIBUTE3            ,
               p_OLD_ATTRIBUTE4                      => l_pricing_attribs_rec.ATTRIBUTE4       ,
               p_NEW_ATTRIBUTE4                      => l_temp_pricing_attribs_rec.ATTRIBUTE4            ,
               p_OLD_ATTRIBUTE5                      => l_pricing_attribs_rec.ATTRIBUTE5       ,
               p_NEW_ATTRIBUTE5                      => l_temp_pricing_attribs_rec.ATTRIBUTE5            ,
               p_OLD_ATTRIBUTE6                      => l_pricing_attribs_rec.ATTRIBUTE6       ,
               p_NEW_ATTRIBUTE6                      => l_temp_pricing_attribs_rec.ATTRIBUTE6            ,
               p_OLD_ATTRIBUTE7                      => l_pricing_attribs_rec.ATTRIBUTE7       ,
               p_NEW_ATTRIBUTE7                      => l_temp_pricing_attribs_rec.ATTRIBUTE7            ,
               p_OLD_ATTRIBUTE8                      => l_pricing_attribs_rec.ATTRIBUTE8       ,
               p_NEW_ATTRIBUTE8                      => l_temp_pricing_attribs_rec.ATTRIBUTE8            ,
               p_OLD_ATTRIBUTE9                      => l_pricing_attribs_rec.ATTRIBUTE9       ,
               p_NEW_ATTRIBUTE9                      => l_temp_pricing_attribs_rec.ATTRIBUTE9            ,
               p_OLD_ATTRIBUTE10                     => l_pricing_attribs_rec.ATTRIBUTE10      ,
               p_NEW_ATTRIBUTE10                     => l_temp_pricing_attribs_rec.ATTRIBUTE10           ,
               p_OLD_ATTRIBUTE11                     => l_pricing_attribs_rec.ATTRIBUTE11      ,
               p_NEW_ATTRIBUTE11                     => l_temp_pricing_attribs_rec.ATTRIBUTE11           ,
               p_OLD_ATTRIBUTE12                     => l_pricing_attribs_rec.ATTRIBUTE12      ,
               p_NEW_ATTRIBUTE12                     => l_temp_pricing_attribs_rec.ATTRIBUTE12           ,
               p_OLD_ATTRIBUTE13                     => l_pricing_attribs_rec.ATTRIBUTE13      ,
               p_NEW_ATTRIBUTE13                     => l_temp_pricing_attribs_rec.ATTRIBUTE13           ,
               p_OLD_ATTRIBUTE14                     => l_pricing_attribs_rec.ATTRIBUTE14      ,
               p_NEW_ATTRIBUTE14                     => l_temp_pricing_attribs_rec.ATTRIBUTE14           ,
               p_OLD_ATTRIBUTE15                     => l_pricing_attribs_rec.ATTRIBUTE15      ,
               p_NEW_ATTRIBUTE15                     => l_temp_pricing_attribs_rec.ATTRIBUTE15           ,
               p_FULL_DUMP_FLAG                      => l_dump_frequency_flag,
               p_CREATED_BY                          => fnd_global.user_id,
               p_CREATION_DATE                       => sysdate,
               p_LAST_UPDATED_BY                     => fnd_global.user_id,
               p_LAST_UPDATE_DATE                    => sysdate,
               p_LAST_UPDATE_LOGIN                   => fnd_global.user_id,
               p_OBJECT_VERSION_NUMBER               => 1);
       ELSE

          l_dump_frequency_flag := 'N';
            -- Grab the input record in a temporary record
          l_temp_pricing_attribs_rec := l_pricing_attribs_rec;
          -- If the mod value is not equal to zero then dump only the changed columns
          -- while the unchanged values have old and new values as null
           IF (p_pricing_attribs_rec.pricing_context = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_context,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_context,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_context := NULL;
                l_pricing_history_rec.new_pricing_context := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_context,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_context,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_context := l_pricing_attribs_rec.pricing_context ;
                l_pricing_history_rec.new_pricing_context := p_pricing_attribs_rec.pricing_context ;
           END IF;
           --
           IF (p_pricing_attribs_rec.pricing_attribute1 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute1,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute1,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute1 := NULL;
                l_pricing_history_rec.new_pricing_attribute1 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute1,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute1,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute1 := l_pricing_attribs_rec.pricing_attribute1 ;
                l_pricing_history_rec.new_pricing_attribute1 := p_pricing_attribs_rec.pricing_attribute1 ;
           END IF;
           --
           IF (p_pricing_attribs_rec.pricing_attribute2 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute2,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute2,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute2 := NULL;
                l_pricing_history_rec.new_pricing_attribute2 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute2,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute2,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute2 := l_pricing_attribs_rec.pricing_attribute2 ;
                l_pricing_history_rec.new_pricing_attribute2 := p_pricing_attribs_rec.pricing_attribute2 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute3 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute3,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute3,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute3 := NULL;
                l_pricing_history_rec.new_pricing_attribute3 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute3,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute3,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute3 := l_pricing_attribs_rec.pricing_attribute3 ;
                l_pricing_history_rec.new_pricing_attribute3 := p_pricing_attribs_rec.pricing_attribute3 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute4 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute4,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute4,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute4 := NULL;
                l_pricing_history_rec.new_pricing_attribute4 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute4,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute4,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute4 := l_pricing_attribs_rec.pricing_attribute4 ;
                l_pricing_history_rec.new_pricing_attribute4 := p_pricing_attribs_rec.pricing_attribute4 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute5 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute5,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute5,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute5 := NULL;
                l_pricing_history_rec.new_pricing_attribute5 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute5,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute5,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute5 := l_pricing_attribs_rec.pricing_attribute5 ;
                l_pricing_history_rec.new_pricing_attribute5 := p_pricing_attribs_rec.pricing_attribute5 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute6 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute6,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute6,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute6 := NULL;
                l_pricing_history_rec.new_pricing_attribute6 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute6,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute6,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute6 := l_pricing_attribs_rec.pricing_attribute6 ;
                l_pricing_history_rec.new_pricing_attribute6 := p_pricing_attribs_rec.pricing_attribute6 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute7 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute7,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute7,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute7 := NULL;
                l_pricing_history_rec.new_pricing_attribute7 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute7,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute7,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute7 := l_pricing_attribs_rec.pricing_attribute7 ;
                l_pricing_history_rec.new_pricing_attribute7 := p_pricing_attribs_rec.pricing_attribute7 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute8 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute8,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute8,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute8 := NULL;
                l_pricing_history_rec.new_pricing_attribute8 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute8,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute8,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute8 := l_pricing_attribs_rec.pricing_attribute8 ;
                l_pricing_history_rec.new_pricing_attribute8 := p_pricing_attribs_rec.pricing_attribute8 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute9 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute9,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute9,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute9 := NULL;
                l_pricing_history_rec.new_pricing_attribute9 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute9,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute9,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute9 := l_pricing_attribs_rec.pricing_attribute9 ;
                l_pricing_history_rec.new_pricing_attribute9 := p_pricing_attribs_rec.pricing_attribute9 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute10 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute10,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute10,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute10 := NULL;
                l_pricing_history_rec.new_pricing_attribute10 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute10,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute10,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute10 := l_pricing_attribs_rec.pricing_attribute10 ;
                l_pricing_history_rec.new_pricing_attribute10 := p_pricing_attribs_rec.pricing_attribute10 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute11 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute11,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute11,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute11 := NULL;
                l_pricing_history_rec.new_pricing_attribute11 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute11,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute11,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute11 := l_pricing_attribs_rec.pricing_attribute11 ;
                l_pricing_history_rec.new_pricing_attribute11 := p_pricing_attribs_rec.pricing_attribute11 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute12 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute12,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute12,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute12 := NULL;
                l_pricing_history_rec.new_pricing_attribute12 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute12,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute12,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute12 := l_pricing_attribs_rec.pricing_attribute12 ;
                l_pricing_history_rec.new_pricing_attribute12 := p_pricing_attribs_rec.pricing_attribute12 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute13 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute13,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute13,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute13 := NULL;
                l_pricing_history_rec.new_pricing_attribute13 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute13,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute13,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute13 := l_pricing_attribs_rec.pricing_attribute13 ;
                l_pricing_history_rec.new_pricing_attribute13 := p_pricing_attribs_rec.pricing_attribute13 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute14 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute14,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute14,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute14 := NULL;
                l_pricing_history_rec.new_pricing_attribute14 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute14,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute14,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute14 := l_pricing_attribs_rec.pricing_attribute14 ;
                l_pricing_history_rec.new_pricing_attribute14 := p_pricing_attribs_rec.pricing_attribute14 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute15 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute15,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute15,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute15 := NULL;
                l_pricing_history_rec.new_pricing_attribute15 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute15,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute15,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute15 := l_pricing_attribs_rec.pricing_attribute15 ;
                l_pricing_history_rec.new_pricing_attribute15 := p_pricing_attribs_rec.pricing_attribute15 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute16 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute16,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute16,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute16 := NULL;
                l_pricing_history_rec.new_pricing_attribute16 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute16,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute16,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute16 := l_pricing_attribs_rec.pricing_attribute16 ;
                l_pricing_history_rec.new_pricing_attribute16 := p_pricing_attribs_rec.pricing_attribute16 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute17 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute17,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute17,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute17 := NULL;
                l_pricing_history_rec.new_pricing_attribute17 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute17,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute17,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute17 := l_pricing_attribs_rec.pricing_attribute17 ;
                l_pricing_history_rec.new_pricing_attribute17 := p_pricing_attribs_rec.pricing_attribute17 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute18 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute18,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute18,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute18 := NULL;
                l_pricing_history_rec.new_pricing_attribute18 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute18,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute18,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute18 := l_pricing_attribs_rec.pricing_attribute18 ;
                l_pricing_history_rec.new_pricing_attribute18 := p_pricing_attribs_rec.pricing_attribute18 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute19 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute19,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute19,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute19 := NULL;
                l_pricing_history_rec.new_pricing_attribute19 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute19,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute19,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute19 := l_pricing_attribs_rec.pricing_attribute19 ;
                l_pricing_history_rec.new_pricing_attribute19 := p_pricing_attribs_rec.pricing_attribute19 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute20 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute20,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute20,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute20 := NULL;
                l_pricing_history_rec.new_pricing_attribute20 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute20,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute20,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute20 := l_pricing_attribs_rec.pricing_attribute20 ;
                l_pricing_history_rec.new_pricing_attribute20 := p_pricing_attribs_rec.pricing_attribute20 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute21 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute21,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute21,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute21 := NULL;
                l_pricing_history_rec.new_pricing_attribute21 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute21,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute21,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute21 := l_pricing_attribs_rec.pricing_attribute21 ;
                l_pricing_history_rec.new_pricing_attribute21 := p_pricing_attribs_rec.pricing_attribute21 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute22 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute22,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute22,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute22 := NULL;
                l_pricing_history_rec.new_pricing_attribute22 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute22,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute22,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute22 := l_pricing_attribs_rec.pricing_attribute22 ;
                l_pricing_history_rec.new_pricing_attribute22 := p_pricing_attribs_rec.pricing_attribute22 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute23 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute23,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute23,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute23 := NULL;
                l_pricing_history_rec.new_pricing_attribute23 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute23,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute23,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute23 := l_pricing_attribs_rec.pricing_attribute23 ;
                l_pricing_history_rec.new_pricing_attribute23 := p_pricing_attribs_rec.pricing_attribute23 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute24 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute24,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute24,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute24 := NULL;
                l_pricing_history_rec.new_pricing_attribute24 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute24,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute24,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute24 := l_pricing_attribs_rec.pricing_attribute24 ;
                l_pricing_history_rec.new_pricing_attribute24 := p_pricing_attribs_rec.pricing_attribute24 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute25 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute25,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute25,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute25 := NULL;
                l_pricing_history_rec.new_pricing_attribute25 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute25,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute25,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute25 := l_pricing_attribs_rec.pricing_attribute25 ;
                l_pricing_history_rec.new_pricing_attribute25 := p_pricing_attribs_rec.pricing_attribute25 ;
           END IF;
           --
           IF (p_pricing_attribs_rec.pricing_attribute26 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute26,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute26,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute26 := NULL;
                l_pricing_history_rec.new_pricing_attribute26 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute26,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute26,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute26 := l_pricing_attribs_rec.pricing_attribute26 ;
                l_pricing_history_rec.new_pricing_attribute26 := p_pricing_attribs_rec.pricing_attribute26 ;
           END IF;
           --
           IF (p_pricing_attribs_rec.pricing_attribute27 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute27,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute27,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute27 := NULL;
                l_pricing_history_rec.new_pricing_attribute27 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute27,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute27,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute27 := l_pricing_attribs_rec.pricing_attribute27 ;
                l_pricing_history_rec.new_pricing_attribute27 := p_pricing_attribs_rec.pricing_attribute27 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute28 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute28,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute28,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute28 := NULL;
                l_pricing_history_rec.new_pricing_attribute28 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute28,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute28,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute28 := l_pricing_attribs_rec.pricing_attribute28 ;
                l_pricing_history_rec.new_pricing_attribute28 := p_pricing_attribs_rec.pricing_attribute28 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute29 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute29,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute29,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute29 := NULL;
                l_pricing_history_rec.new_pricing_attribute29 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute29,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute29,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute29 := l_pricing_attribs_rec.pricing_attribute29 ;
                l_pricing_history_rec.new_pricing_attribute29 := p_pricing_attribs_rec.pricing_attribute29 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute30 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute30,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute30,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute30 := NULL;
                l_pricing_history_rec.new_pricing_attribute30 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute30,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute30,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute30 := l_pricing_attribs_rec.pricing_attribute30 ;
                l_pricing_history_rec.new_pricing_attribute30 := p_pricing_attribs_rec.pricing_attribute30 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute31 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute31,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute31,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute31 := NULL;
                l_pricing_history_rec.new_pricing_attribute31 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute31,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute31,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute31 := l_pricing_attribs_rec.pricing_attribute31 ;
                l_pricing_history_rec.new_pricing_attribute31 := p_pricing_attribs_rec.pricing_attribute31 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute32 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute32,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute32,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute32 := NULL;
                l_pricing_history_rec.new_pricing_attribute32 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute32,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute32,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute32 := l_pricing_attribs_rec.pricing_attribute32 ;
                l_pricing_history_rec.new_pricing_attribute32 := p_pricing_attribs_rec.pricing_attribute32 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute33 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute33,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute33,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute33 := NULL;
                l_pricing_history_rec.new_pricing_attribute33 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute33,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute33,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute33 := l_pricing_attribs_rec.pricing_attribute33 ;
                l_pricing_history_rec.new_pricing_attribute33 := p_pricing_attribs_rec.pricing_attribute33 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute34 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute34,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute34,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute34 := NULL;
                l_pricing_history_rec.new_pricing_attribute34 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute34,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute34,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute34 := l_pricing_attribs_rec.pricing_attribute34 ;
                l_pricing_history_rec.new_pricing_attribute34 := p_pricing_attribs_rec.pricing_attribute34 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute35 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute35,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute35,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute35 := NULL;
                l_pricing_history_rec.new_pricing_attribute35 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute35,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute35,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute35 := l_pricing_attribs_rec.pricing_attribute35 ;
                l_pricing_history_rec.new_pricing_attribute35 := p_pricing_attribs_rec.pricing_attribute35 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute36 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute36,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute36,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute36 := NULL;
                l_pricing_history_rec.new_pricing_attribute36 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute36,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute36,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute36 := l_pricing_attribs_rec.pricing_attribute36 ;
                l_pricing_history_rec.new_pricing_attribute36 := p_pricing_attribs_rec.pricing_attribute36 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute37 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute37,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute37,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute37 := NULL;
                l_pricing_history_rec.new_pricing_attribute37 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute37,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute37,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute37 := l_pricing_attribs_rec.pricing_attribute37 ;
                l_pricing_history_rec.new_pricing_attribute37 := p_pricing_attribs_rec.pricing_attribute37 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute38 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute38,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute38,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute38 := NULL;
                l_pricing_history_rec.new_pricing_attribute38 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute38,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute38,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute38 := l_pricing_attribs_rec.pricing_attribute38 ;
                l_pricing_history_rec.new_pricing_attribute38 := p_pricing_attribs_rec.pricing_attribute38 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute39 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute39,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute39,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute39 := NULL;
                l_pricing_history_rec.new_pricing_attribute39 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute39,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute39,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute39 := l_pricing_attribs_rec.pricing_attribute39 ;
                l_pricing_history_rec.new_pricing_attribute39 := p_pricing_attribs_rec.pricing_attribute39 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute40 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute40,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute40,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute40 := NULL;
                l_pricing_history_rec.new_pricing_attribute40 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute40,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute40,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute40 := l_pricing_attribs_rec.pricing_attribute40 ;
                l_pricing_history_rec.new_pricing_attribute40 := p_pricing_attribs_rec.pricing_attribute40 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute41 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute41,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute41,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute41 := NULL;
                l_pricing_history_rec.new_pricing_attribute41 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute41,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute41,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute41 := l_pricing_attribs_rec.pricing_attribute41 ;
                l_pricing_history_rec.new_pricing_attribute41 := p_pricing_attribs_rec.pricing_attribute41 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute42 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute42,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute42,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute42 := NULL;
                l_pricing_history_rec.new_pricing_attribute42 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute42,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute42,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute42 := l_pricing_attribs_rec.pricing_attribute42 ;
                l_pricing_history_rec.new_pricing_attribute42 := p_pricing_attribs_rec.pricing_attribute42 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute43 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute43,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute43,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute43 := NULL;
                l_pricing_history_rec.new_pricing_attribute43 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute43,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute43,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute43 := l_pricing_attribs_rec.pricing_attribute43 ;
                l_pricing_history_rec.new_pricing_attribute43 := p_pricing_attribs_rec.pricing_attribute43 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute44 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute44,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute44,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute44 := NULL;
                l_pricing_history_rec.new_pricing_attribute44 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute44,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute44,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute44 := l_pricing_attribs_rec.pricing_attribute44 ;
                l_pricing_history_rec.new_pricing_attribute44 := p_pricing_attribs_rec.pricing_attribute44 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute45 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute45,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute45,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute45 := NULL;
                l_pricing_history_rec.new_pricing_attribute45 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute45,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute45,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute45 := l_pricing_attribs_rec.pricing_attribute45 ;
                l_pricing_history_rec.new_pricing_attribute45 := p_pricing_attribs_rec.pricing_attribute45 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute46 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute46,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute46,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute46 := NULL;
                l_pricing_history_rec.new_pricing_attribute46 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute46,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute46,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute46 := l_pricing_attribs_rec.pricing_attribute46 ;
                l_pricing_history_rec.new_pricing_attribute46 := p_pricing_attribs_rec.pricing_attribute46 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute47 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute47,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute47,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute47 := NULL;
                l_pricing_history_rec.new_pricing_attribute47 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute47,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute47,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute47 := l_pricing_attribs_rec.pricing_attribute47 ;
                l_pricing_history_rec.new_pricing_attribute47 := p_pricing_attribs_rec.pricing_attribute47 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute48 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute48,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute48,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute48 := NULL;
                l_pricing_history_rec.new_pricing_attribute48 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute48,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute48,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute48 := l_pricing_attribs_rec.pricing_attribute48 ;
                l_pricing_history_rec.new_pricing_attribute48 := p_pricing_attribs_rec.pricing_attribute48 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute49 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute49,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute49,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute49 := NULL;
                l_pricing_history_rec.new_pricing_attribute49 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute49,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute49,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute49 := l_pricing_attribs_rec.pricing_attribute49 ;
                l_pricing_history_rec.new_pricing_attribute49 := p_pricing_attribs_rec.pricing_attribute49 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute50 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute50,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute50,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute50 := NULL;
                l_pricing_history_rec.new_pricing_attribute50 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute50,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute50,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute50 := l_pricing_attribs_rec.pricing_attribute50 ;
                l_pricing_history_rec.new_pricing_attribute50 := p_pricing_attribs_rec.pricing_attribute50 ;
           END IF;
           --
           IF (p_pricing_attribs_rec.pricing_attribute51 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute51,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute51,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute51 := NULL;
                l_pricing_history_rec.new_pricing_attribute51 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute51,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute51,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute51 := l_pricing_attribs_rec.pricing_attribute51 ;
                l_pricing_history_rec.new_pricing_attribute51 := p_pricing_attribs_rec.pricing_attribute51 ;
           END IF;
           --
           IF (p_pricing_attribs_rec.pricing_attribute52 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute52,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute52,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute52 := NULL;
                l_pricing_history_rec.new_pricing_attribute52 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute52,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute52,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute52 := l_pricing_attribs_rec.pricing_attribute52 ;
                l_pricing_history_rec.new_pricing_attribute52 := p_pricing_attribs_rec.pricing_attribute52 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute53 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute53,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute53,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute53 := NULL;
                l_pricing_history_rec.new_pricing_attribute53 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute53,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute53,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute53 := l_pricing_attribs_rec.pricing_attribute53 ;
                l_pricing_history_rec.new_pricing_attribute53 := p_pricing_attribs_rec.pricing_attribute53 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute54 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute54,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute54,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute54 := NULL;
                l_pricing_history_rec.new_pricing_attribute54 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute54,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute54,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute54 := l_pricing_attribs_rec.pricing_attribute54 ;
                l_pricing_history_rec.new_pricing_attribute54 := p_pricing_attribs_rec.pricing_attribute54 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute55 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute55,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute55,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute55 := NULL;
                l_pricing_history_rec.new_pricing_attribute55 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute55,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute55,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute55 := l_pricing_attribs_rec.pricing_attribute55 ;
                l_pricing_history_rec.new_pricing_attribute55 := p_pricing_attribs_rec.pricing_attribute55 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute56 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute56,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute56,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute56 := NULL;
                l_pricing_history_rec.new_pricing_attribute56 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute56,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute56,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute56 := l_pricing_attribs_rec.pricing_attribute56 ;
                l_pricing_history_rec.new_pricing_attribute56 := p_pricing_attribs_rec.pricing_attribute56 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute57 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute57,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute57,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute57 := NULL;
                l_pricing_history_rec.new_pricing_attribute57 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute57,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute57,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute57 := l_pricing_attribs_rec.pricing_attribute57 ;
                l_pricing_history_rec.new_pricing_attribute57 := p_pricing_attribs_rec.pricing_attribute57 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute58 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute58,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute58,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute58 := NULL;
                l_pricing_history_rec.new_pricing_attribute58 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute58,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute58,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute58 := l_pricing_attribs_rec.pricing_attribute58 ;
                l_pricing_history_rec.new_pricing_attribute58 := p_pricing_attribs_rec.pricing_attribute58 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute59 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute59,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute59,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute59 := NULL;
                l_pricing_history_rec.new_pricing_attribute59 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute59,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute59,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute59 := l_pricing_attribs_rec.pricing_attribute59 ;
                l_pricing_history_rec.new_pricing_attribute59 := p_pricing_attribs_rec.pricing_attribute59 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute60 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute60,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute60,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute60 := NULL;
                l_pricing_history_rec.new_pricing_attribute60 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute60,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute60,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute60 := l_pricing_attribs_rec.pricing_attribute60 ;
                l_pricing_history_rec.new_pricing_attribute60 := p_pricing_attribs_rec.pricing_attribute60 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute61 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute61,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute61,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute61 := NULL;
                l_pricing_history_rec.new_pricing_attribute61 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute61,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute61,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute61 := l_pricing_attribs_rec.pricing_attribute61 ;
                l_pricing_history_rec.new_pricing_attribute61 := p_pricing_attribs_rec.pricing_attribute61 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute62 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute62,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute62,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute62 := NULL;
                l_pricing_history_rec.new_pricing_attribute62 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute62,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute62,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute62 := l_pricing_attribs_rec.pricing_attribute62 ;
                l_pricing_history_rec.new_pricing_attribute62 := p_pricing_attribs_rec.pricing_attribute62 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute63 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute63,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute63,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute63 := NULL;
                l_pricing_history_rec.new_pricing_attribute63 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute63,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute63,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute63 := l_pricing_attribs_rec.pricing_attribute63 ;
                l_pricing_history_rec.new_pricing_attribute63 := p_pricing_attribs_rec.pricing_attribute63 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute64 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute64,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute64,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute64 := NULL;
                l_pricing_history_rec.new_pricing_attribute64 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute64,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute64,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute64 := l_pricing_attribs_rec.pricing_attribute64 ;
                l_pricing_history_rec.new_pricing_attribute64 := p_pricing_attribs_rec.pricing_attribute64 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute65 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute65,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute65,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute65 := NULL;
                l_pricing_history_rec.new_pricing_attribute65 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute65,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute65,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute65 := l_pricing_attribs_rec.pricing_attribute65 ;
                l_pricing_history_rec.new_pricing_attribute65 := p_pricing_attribs_rec.pricing_attribute65 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute66 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute66,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute66,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute66 := NULL;
                l_pricing_history_rec.new_pricing_attribute66 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute66,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute66,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute66 := l_pricing_attribs_rec.pricing_attribute66 ;
                l_pricing_history_rec.new_pricing_attribute66 := p_pricing_attribs_rec.pricing_attribute66 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute67 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute67,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute67,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute67 := NULL;
                l_pricing_history_rec.new_pricing_attribute67 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute67,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute67,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute67 := l_pricing_attribs_rec.pricing_attribute67 ;
                l_pricing_history_rec.new_pricing_attribute67 := p_pricing_attribs_rec.pricing_attribute67 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute68 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute68,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute68,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute68 := NULL;
                l_pricing_history_rec.new_pricing_attribute68 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute68,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute68,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute68 := l_pricing_attribs_rec.pricing_attribute68 ;
                l_pricing_history_rec.new_pricing_attribute68 := p_pricing_attribs_rec.pricing_attribute68 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute69 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute69,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute69,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute69 := NULL;
                l_pricing_history_rec.new_pricing_attribute69 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute69,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute69,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute69 := l_pricing_attribs_rec.pricing_attribute69 ;
                l_pricing_history_rec.new_pricing_attribute69 := p_pricing_attribs_rec.pricing_attribute69 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute70 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute70,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute70,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute70 := NULL;
                l_pricing_history_rec.new_pricing_attribute70 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute70,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute70,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute70 := l_pricing_attribs_rec.pricing_attribute70 ;
                l_pricing_history_rec.new_pricing_attribute70 := p_pricing_attribs_rec.pricing_attribute70 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute71 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute71,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute71,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute71 := NULL;
                l_pricing_history_rec.new_pricing_attribute71 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute71,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute71,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute71 := l_pricing_attribs_rec.pricing_attribute71 ;
                l_pricing_history_rec.new_pricing_attribute71 := p_pricing_attribs_rec.pricing_attribute71 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute72 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute72,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute72,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute72 := NULL;
                l_pricing_history_rec.new_pricing_attribute72 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute72,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute72,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute72 := l_pricing_attribs_rec.pricing_attribute72 ;
                l_pricing_history_rec.new_pricing_attribute72 := p_pricing_attribs_rec.pricing_attribute72 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute73 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute73,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute73,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute73 := NULL;
                l_pricing_history_rec.new_pricing_attribute73 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute73,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute73,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute73 := l_pricing_attribs_rec.pricing_attribute73 ;
                l_pricing_history_rec.new_pricing_attribute73 := p_pricing_attribs_rec.pricing_attribute73 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute74 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute74,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute74,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute74 := NULL;
                l_pricing_history_rec.new_pricing_attribute74 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute74,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute74,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute74 := l_pricing_attribs_rec.pricing_attribute74 ;
                l_pricing_history_rec.new_pricing_attribute74 := p_pricing_attribs_rec.pricing_attribute74 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute75 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute75,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute75,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute75 := NULL;
                l_pricing_history_rec.new_pricing_attribute75 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute75,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute75,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute75 := l_pricing_attribs_rec.pricing_attribute75 ;
                l_pricing_history_rec.new_pricing_attribute75 := p_pricing_attribs_rec.pricing_attribute75 ;
           END IF;
           --
           IF (p_pricing_attribs_rec.pricing_attribute76 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute76,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute76,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute76 := NULL;
                l_pricing_history_rec.new_pricing_attribute76 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute76,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute76,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute76 := l_pricing_attribs_rec.pricing_attribute76 ;
                l_pricing_history_rec.new_pricing_attribute76 := p_pricing_attribs_rec.pricing_attribute76 ;
           END IF;
           --
           IF (p_pricing_attribs_rec.pricing_attribute77 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute77,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute77,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute77 := NULL;
                l_pricing_history_rec.new_pricing_attribute77 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute77,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute77,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute77 := l_pricing_attribs_rec.pricing_attribute77 ;
                l_pricing_history_rec.new_pricing_attribute77 := p_pricing_attribs_rec.pricing_attribute77 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute78 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute78,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute78,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute78 := NULL;
                l_pricing_history_rec.new_pricing_attribute78 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute78,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute78,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute78 := l_pricing_attribs_rec.pricing_attribute78 ;
                l_pricing_history_rec.new_pricing_attribute78 := p_pricing_attribs_rec.pricing_attribute78 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute79 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute79,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute79,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute79 := NULL;
                l_pricing_history_rec.new_pricing_attribute79 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute79,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute79,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute79 := l_pricing_attribs_rec.pricing_attribute79 ;
                l_pricing_history_rec.new_pricing_attribute79 := p_pricing_attribs_rec.pricing_attribute79 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute80 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute80,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute80,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute80 := NULL;
                l_pricing_history_rec.new_pricing_attribute80 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute80,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute80,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute80 := l_pricing_attribs_rec.pricing_attribute80 ;
                l_pricing_history_rec.new_pricing_attribute80 := p_pricing_attribs_rec.pricing_attribute80 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute81 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute81,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute81,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute81 := NULL;
                l_pricing_history_rec.new_pricing_attribute81 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute81,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute81,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute81 := l_pricing_attribs_rec.pricing_attribute81 ;
                l_pricing_history_rec.new_pricing_attribute81 := p_pricing_attribs_rec.pricing_attribute81 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute82 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute82,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute82,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute82 := NULL;
                l_pricing_history_rec.new_pricing_attribute82 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute82,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute82,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute82 := l_pricing_attribs_rec.pricing_attribute82 ;
                l_pricing_history_rec.new_pricing_attribute82 := p_pricing_attribs_rec.pricing_attribute82 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute83 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute83,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute83,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute83 := NULL;
                l_pricing_history_rec.new_pricing_attribute83 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute83,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute83,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute83 := l_pricing_attribs_rec.pricing_attribute83 ;
                l_pricing_history_rec.new_pricing_attribute83 := p_pricing_attribs_rec.pricing_attribute83 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute84 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute84,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute84,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute84 := NULL;
                l_pricing_history_rec.new_pricing_attribute84 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute84,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute84,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute84 := l_pricing_attribs_rec.pricing_attribute84 ;
                l_pricing_history_rec.new_pricing_attribute84 := p_pricing_attribs_rec.pricing_attribute84 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute85 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute85,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute85,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute85 := NULL;
                l_pricing_history_rec.new_pricing_attribute85 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute85,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute85,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute85 := l_pricing_attribs_rec.pricing_attribute85 ;
                l_pricing_history_rec.new_pricing_attribute85 := p_pricing_attribs_rec.pricing_attribute85 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute86 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute86,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute86,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute86 := NULL;
                l_pricing_history_rec.new_pricing_attribute86 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute86,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute86,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute86 := l_pricing_attribs_rec.pricing_attribute86 ;
                l_pricing_history_rec.new_pricing_attribute86 := p_pricing_attribs_rec.pricing_attribute86 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute87 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute87,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute87,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute87 := NULL;
                l_pricing_history_rec.new_pricing_attribute87 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute87,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute87,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute87 := l_pricing_attribs_rec.pricing_attribute87 ;
                l_pricing_history_rec.new_pricing_attribute87 := p_pricing_attribs_rec.pricing_attribute87 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute88 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute88,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute88,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute88 := NULL;
                l_pricing_history_rec.new_pricing_attribute88 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute88,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute88,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute88 := l_pricing_attribs_rec.pricing_attribute88 ;
                l_pricing_history_rec.new_pricing_attribute88 := p_pricing_attribs_rec.pricing_attribute88 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute89 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute89,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute89,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute89 := NULL;
                l_pricing_history_rec.new_pricing_attribute89 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute89,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute89,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute89 := l_pricing_attribs_rec.pricing_attribute89 ;
                l_pricing_history_rec.new_pricing_attribute89 := p_pricing_attribs_rec.pricing_attribute89 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute90 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute90,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute90,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute90 := NULL;
                l_pricing_history_rec.new_pricing_attribute90 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute90,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute90,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute90 := l_pricing_attribs_rec.pricing_attribute90 ;
                l_pricing_history_rec.new_pricing_attribute90 := p_pricing_attribs_rec.pricing_attribute90 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute91 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute91,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute91,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute91 := NULL;
                l_pricing_history_rec.new_pricing_attribute91 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute91,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute91,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute91 := l_pricing_attribs_rec.pricing_attribute91 ;
                l_pricing_history_rec.new_pricing_attribute91 := p_pricing_attribs_rec.pricing_attribute91 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute92 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute92,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute92,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute92 := NULL;
                l_pricing_history_rec.new_pricing_attribute92 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute92,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute92,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute92 := l_pricing_attribs_rec.pricing_attribute92 ;
                l_pricing_history_rec.new_pricing_attribute92 := p_pricing_attribs_rec.pricing_attribute92 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute93 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute93,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute93,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute93 := NULL;
                l_pricing_history_rec.new_pricing_attribute93 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute93,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute93,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute93 := l_pricing_attribs_rec.pricing_attribute93 ;
                l_pricing_history_rec.new_pricing_attribute93 := p_pricing_attribs_rec.pricing_attribute93 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute94 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute94,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute94,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute94 := NULL;
                l_pricing_history_rec.new_pricing_attribute94 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute94,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute94,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute94 := l_pricing_attribs_rec.pricing_attribute94 ;
                l_pricing_history_rec.new_pricing_attribute94 := p_pricing_attribs_rec.pricing_attribute94 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute95 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute95,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute95,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute95 := NULL;
                l_pricing_history_rec.new_pricing_attribute95 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute95,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute95,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute95 := l_pricing_attribs_rec.pricing_attribute95 ;
                l_pricing_history_rec.new_pricing_attribute95 := p_pricing_attribs_rec.pricing_attribute95 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute96 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute96,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute96,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute96 := NULL;
                l_pricing_history_rec.new_pricing_attribute96 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute96,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute96,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute96 := l_pricing_attribs_rec.pricing_attribute96 ;
                l_pricing_history_rec.new_pricing_attribute96 := p_pricing_attribs_rec.pricing_attribute96 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute97 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute97,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute97,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute97 := NULL;
                l_pricing_history_rec.new_pricing_attribute97 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute97,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute97,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute97 := l_pricing_attribs_rec.pricing_attribute97 ;
                l_pricing_history_rec.new_pricing_attribute97 := p_pricing_attribs_rec.pricing_attribute97 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute98 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute98,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute98,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute98 := NULL;
                l_pricing_history_rec.new_pricing_attribute98 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute98,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute98,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute98 := l_pricing_attribs_rec.pricing_attribute98 ;
                l_pricing_history_rec.new_pricing_attribute98 := p_pricing_attribs_rec.pricing_attribute98 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute99 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute99,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute99,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute99 := NULL;
                l_pricing_history_rec.new_pricing_attribute99 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute99,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute99,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute99 := l_pricing_attribs_rec.pricing_attribute99 ;
                l_pricing_history_rec.new_pricing_attribute99 := p_pricing_attribs_rec.pricing_attribute99 ;
           END IF;
           IF (p_pricing_attribs_rec.pricing_attribute100 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.pricing_attribute100,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.pricing_attribute100,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute100 := NULL;
                l_pricing_history_rec.new_pricing_attribute100 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.pricing_attribute100,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.pricing_attribute100,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_pricing_attribute100 := l_pricing_attribs_rec.pricing_attribute100 ;
                l_pricing_history_rec.new_pricing_attribute100 := p_pricing_attribs_rec.pricing_attribute100 ;
           END IF;
           IF (p_pricing_attribs_rec.active_start_date = fnd_api.g_miss_date) OR
              NVL(l_pricing_attribs_rec.active_start_date,fnd_api.g_miss_date) = NVL(p_pricing_attribs_rec.active_start_date,fnd_api.g_miss_date) THEN
                l_pricing_history_rec.old_active_start_date := NULL;
                l_pricing_history_rec.new_active_start_date := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.active_start_date,fnd_api.g_miss_date) <> NVL(p_pricing_attribs_rec.active_start_date,fnd_api.g_miss_date) THEN
                l_pricing_history_rec.old_active_start_date := l_pricing_attribs_rec.active_start_date ;
                l_pricing_history_rec.new_active_start_date := p_pricing_attribs_rec.active_start_date ;
           END IF;
           --
           IF (p_pricing_attribs_rec.active_end_date = fnd_api.g_miss_date) OR
              NVL(l_pricing_attribs_rec.active_end_date,fnd_api.g_miss_date) = NVL(p_pricing_attribs_rec.active_end_date,fnd_api.g_miss_date) THEN
                l_pricing_history_rec.old_active_end_date := NULL;
                l_pricing_history_rec.new_active_end_date := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.active_end_date,fnd_api.g_miss_date) <> NVL(p_pricing_attribs_rec.active_end_date,fnd_api.g_miss_date) THEN
                l_pricing_history_rec.old_active_end_date := l_pricing_attribs_rec.active_end_date ;
                l_pricing_history_rec.new_active_end_date := p_pricing_attribs_rec.active_end_date ;
           END IF;
           --
           IF (p_pricing_attribs_rec.context = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.context,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.context,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_context := NULL;
                l_pricing_history_rec.new_context := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.context,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.context,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_context := l_pricing_attribs_rec.context ;
                l_pricing_history_rec.new_context := p_pricing_attribs_rec.context ;
           END IF;
           IF (p_pricing_attribs_rec.attribute1 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute1,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute1,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute1 := NULL;
                l_pricing_history_rec.new_attribute1 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute1,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute1,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute1 := l_pricing_attribs_rec.attribute1 ;
                l_pricing_history_rec.new_attribute1 := p_pricing_attribs_rec.attribute1 ;
           END IF;
           --
           IF (p_pricing_attribs_rec.attribute2 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute2,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute2,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute2 := NULL;
                l_pricing_history_rec.new_attribute2 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute2,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute2,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute2 := l_pricing_attribs_rec.attribute2 ;
                l_pricing_history_rec.new_attribute2 := p_pricing_attribs_rec.attribute2 ;
           END IF;
           IF (p_pricing_attribs_rec.attribute3 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute3,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute3,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute3 := NULL;
                l_pricing_history_rec.new_attribute3 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute3,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute3,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute3 := l_pricing_attribs_rec.attribute3 ;
                l_pricing_history_rec.new_attribute3 := p_pricing_attribs_rec.attribute3 ;
           END IF;
           IF (p_pricing_attribs_rec.attribute4 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute4,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute4,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute4 := NULL;
                l_pricing_history_rec.new_attribute4 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute4,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute4,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute4 := l_pricing_attribs_rec.attribute4 ;
                l_pricing_history_rec.new_attribute4 := p_pricing_attribs_rec.attribute4 ;
           END IF;
           IF (p_pricing_attribs_rec.attribute5 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute5,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute5,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute5 := NULL;
                l_pricing_history_rec.new_attribute5 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute5,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute5,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute5 := l_pricing_attribs_rec.attribute5 ;
                l_pricing_history_rec.new_attribute5 := p_pricing_attribs_rec.attribute5 ;
           END IF;
           IF (p_pricing_attribs_rec.attribute6 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute6,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute6,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute6 := NULL;
                l_pricing_history_rec.new_attribute6 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute6,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute6,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute6 := l_pricing_attribs_rec.attribute6 ;
                l_pricing_history_rec.new_attribute6 := p_pricing_attribs_rec.attribute6 ;
           END IF;
           IF (p_pricing_attribs_rec.attribute7 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute7,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute7,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute7 := NULL;
                l_pricing_history_rec.new_attribute7 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute7,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute7,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute7 := l_pricing_attribs_rec.attribute7 ;
                l_pricing_history_rec.new_attribute7 := p_pricing_attribs_rec.attribute7 ;
           END IF;
           IF (p_pricing_attribs_rec.attribute8 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute8,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute8,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute8 := NULL;
                l_pricing_history_rec.new_attribute8 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute8,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute8,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute8 := l_pricing_attribs_rec.attribute8 ;
                l_pricing_history_rec.new_attribute8 := p_pricing_attribs_rec.attribute8 ;
           END IF;
           IF (p_pricing_attribs_rec.attribute9 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute9,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute9,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute9 := NULL;
                l_pricing_history_rec.new_attribute9 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute9,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute9,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute9 := l_pricing_attribs_rec.attribute9 ;
                l_pricing_history_rec.new_attribute9 := p_pricing_attribs_rec.attribute9 ;
           END IF;
           IF (p_pricing_attribs_rec.attribute10 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute10,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute10,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute10 := NULL;
                l_pricing_history_rec.new_attribute10 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute10,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute10,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute10 := l_pricing_attribs_rec.attribute10 ;
                l_pricing_history_rec.new_attribute10 := p_pricing_attribs_rec.attribute10 ;
           END IF;
           IF (p_pricing_attribs_rec.attribute11 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute11,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute11,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute11 := NULL;
                l_pricing_history_rec.new_attribute11 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute11,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute11,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute11 := l_pricing_attribs_rec.attribute11 ;
                l_pricing_history_rec.new_attribute11 := p_pricing_attribs_rec.attribute11 ;
           END IF;
           IF (p_pricing_attribs_rec.attribute12 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute12,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute12,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute12 := NULL;
                l_pricing_history_rec.new_attribute12 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute12,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute12,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute12 := l_pricing_attribs_rec.attribute12 ;
                l_pricing_history_rec.new_attribute12 := p_pricing_attribs_rec.attribute12 ;
           END IF;
           IF (p_pricing_attribs_rec.attribute13 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute13,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute13,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute13 := NULL;
                l_pricing_history_rec.new_attribute13 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute13,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute13,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute13 := l_pricing_attribs_rec.attribute13 ;
                l_pricing_history_rec.new_attribute13 := p_pricing_attribs_rec.attribute13 ;
           END IF;
           IF (p_pricing_attribs_rec.attribute14 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute14,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute14,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute14 := NULL;
                l_pricing_history_rec.new_attribute14 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute14,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute14,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute14 := l_pricing_attribs_rec.attribute14 ;
                l_pricing_history_rec.new_attribute14 := p_pricing_attribs_rec.attribute14 ;
           END IF;
           IF (p_pricing_attribs_rec.attribute15 = fnd_api.g_miss_char) OR
              NVL(l_pricing_attribs_rec.attribute15,fnd_api.g_miss_char) = NVL(p_pricing_attribs_rec.attribute15,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute15 := NULL;
                l_pricing_history_rec.new_attribute15 := NULL;
           ELSIF
              NVL(l_pricing_attribs_rec.attribute15,fnd_api.g_miss_char) <> NVL(p_pricing_attribs_rec.attribute15,fnd_api.g_miss_char) THEN
                l_pricing_history_rec.old_attribute15 := l_pricing_attribs_rec.attribute15 ;
                l_pricing_history_rec.new_attribute15 := p_pricing_attribs_rec.attribute15 ;
           END IF;

        -- Create a history
        CSI_I_PRICING_ATTRIBS_H_PKG.Insert_Row(
          px_PRICE_ATTRIB_HISTORY_ID            => l_pricing_attrib_h_id,
          p_PRICING_ATTRIBUTE_ID                => l_pricing_attrib_id,
          p_TRANSACTION_ID                      => p_txn_rec.transaction_id,
          p_OLD_PRICING_CONTEXT                 => l_pricing_history_rec.old_pricing_context,
          p_NEW_PRICING_CONTEXT                 => l_pricing_history_rec.new_pricing_context,
          p_OLD_PRICING_ATTRIBUTE1              => l_pricing_history_rec.old_pricing_attribute1,
          p_NEW_PRICING_ATTRIBUTE1              => l_pricing_history_rec.new_pricing_attribute1,
          p_OLD_PRICING_ATTRIBUTE2              => l_pricing_history_rec.old_pricing_attribute2,
          p_NEW_PRICING_ATTRIBUTE2              => l_pricing_history_rec.new_pricing_attribute2,
          p_OLD_PRICING_ATTRIBUTE3              => l_pricing_history_rec.old_pricing_attribute3,
          p_NEW_PRICING_ATTRIBUTE3              => l_pricing_history_rec.new_pricing_attribute3,
          p_OLD_PRICING_ATTRIBUTE4              => l_pricing_history_rec.old_pricing_attribute4,
          p_NEW_PRICING_ATTRIBUTE4              => l_pricing_history_rec.new_pricing_attribute4,
          p_OLD_PRICING_ATTRIBUTE5              => l_pricing_history_rec.old_pricing_attribute5,
          p_NEW_PRICING_ATTRIBUTE5              => l_pricing_history_rec.new_pricing_attribute5,
          p_OLD_PRICING_ATTRIBUTE6              => l_pricing_history_rec.old_pricing_attribute6,
          p_NEW_PRICING_ATTRIBUTE6              => l_pricing_history_rec.new_pricing_attribute6,
          p_OLD_PRICING_ATTRIBUTE7              => l_pricing_history_rec.old_pricing_attribute7,
          p_NEW_PRICING_ATTRIBUTE7              => l_pricing_history_rec.new_pricing_attribute7,
          p_OLD_PRICING_ATTRIBUTE8              => l_pricing_history_rec.old_pricing_attribute8,
          p_NEW_PRICING_ATTRIBUTE8              => l_pricing_history_rec.new_pricing_attribute8,
          p_OLD_PRICING_ATTRIBUTE9              => l_pricing_history_rec.old_pricing_attribute9,
          p_NEW_PRICING_ATTRIBUTE9              => l_pricing_history_rec.new_pricing_attribute9,
          p_OLD_PRICING_ATTRIBUTE10             => l_pricing_history_rec.old_pricing_attribute10,
          p_NEW_PRICING_ATTRIBUTE10             => l_pricing_history_rec.new_pricing_attribute10,
          p_OLD_PRICING_ATTRIBUTE11             => l_pricing_history_rec.old_pricing_attribute11,
          p_NEW_PRICING_ATTRIBUTE11             => l_pricing_history_rec.new_pricing_attribute11,
          p_OLD_PRICING_ATTRIBUTE12             => l_pricing_history_rec.old_pricing_attribute12,
          p_NEW_PRICING_ATTRIBUTE12             => l_pricing_history_rec.new_pricing_attribute12,
          p_OLD_PRICING_ATTRIBUTE13             => l_pricing_history_rec.old_pricing_attribute13,
          p_NEW_PRICING_ATTRIBUTE13             => l_pricing_history_rec.new_pricing_attribute13,
          p_OLD_PRICING_ATTRIBUTE14             => l_pricing_history_rec.old_pricing_attribute14,
          p_NEW_PRICING_ATTRIBUTE14             => l_pricing_history_rec.new_pricing_attribute14,
          p_OLD_PRICING_ATTRIBUTE15             => l_pricing_history_rec.old_pricing_attribute15,
          p_NEW_PRICING_ATTRIBUTE15             => l_pricing_history_rec.new_pricing_attribute15,
          p_OLD_PRICING_ATTRIBUTE16             => l_pricing_history_rec.old_pricing_attribute16,
          p_NEW_PRICING_ATTRIBUTE16             => l_pricing_history_rec.new_pricing_attribute16,
          p_OLD_PRICING_ATTRIBUTE17             => l_pricing_history_rec.old_pricing_attribute17,
          p_NEW_PRICING_ATTRIBUTE17             => l_pricing_history_rec.new_pricing_attribute17,
          p_OLD_PRICING_ATTRIBUTE18             => l_pricing_history_rec.old_pricing_attribute18,
          p_NEW_PRICING_ATTRIBUTE18             => l_pricing_history_rec.new_pricing_attribute18,
          p_OLD_PRICING_ATTRIBUTE19             => l_pricing_history_rec.old_pricing_attribute19,
          p_NEW_PRICING_ATTRIBUTE19             => l_pricing_history_rec.new_pricing_attribute19,
          p_OLD_PRICING_ATTRIBUTE20             => l_pricing_history_rec.old_pricing_attribute20,
          p_NEW_PRICING_ATTRIBUTE20             => l_pricing_history_rec.new_pricing_attribute20,
          p_OLD_PRICING_ATTRIBUTE21             => l_pricing_history_rec.old_pricing_attribute21,
          p_NEW_PRICING_ATTRIBUTE21             => l_pricing_history_rec.new_pricing_attribute21,
          p_OLD_PRICING_ATTRIBUTE22             => l_pricing_history_rec.old_pricing_attribute22,
          p_NEW_PRICING_ATTRIBUTE22             => l_pricing_history_rec.new_pricing_attribute22,
          p_OLD_PRICING_ATTRIBUTE23             => l_pricing_history_rec.old_pricing_attribute22,
          p_NEW_PRICING_ATTRIBUTE23             => l_pricing_history_rec.new_pricing_attribute23,
          p_OLD_PRICING_ATTRIBUTE24             => l_pricing_history_rec.old_pricing_attribute24,
          p_NEW_PRICING_ATTRIBUTE24             => l_pricing_history_rec.new_pricing_attribute24,
          p_NEW_PRICING_ATTRIBUTE25             => l_pricing_history_rec.old_pricing_attribute25,
          p_OLD_PRICING_ATTRIBUTE25             => l_pricing_history_rec.new_pricing_attribute25,
          p_OLD_PRICING_ATTRIBUTE26             => l_pricing_history_rec.old_pricing_attribute26,
          p_NEW_PRICING_ATTRIBUTE26             => l_pricing_history_rec.new_pricing_attribute26,
          p_OLD_PRICING_ATTRIBUTE27             => l_pricing_history_rec.old_pricing_attribute27,
          p_NEW_PRICING_ATTRIBUTE27             => l_pricing_history_rec.new_pricing_attribute27,
          p_OLD_PRICING_ATTRIBUTE28             => l_pricing_history_rec.old_pricing_attribute28,
          p_NEW_PRICING_ATTRIBUTE28             => l_pricing_history_rec.new_pricing_attribute28,
          p_OLD_PRICING_ATTRIBUTE29             => l_pricing_history_rec.old_pricing_attribute29,
          p_NEW_PRICING_ATTRIBUTE29             => l_pricing_history_rec.new_pricing_attribute29,
          p_OLD_PRICING_ATTRIBUTE30             => l_pricing_history_rec.old_pricing_attribute30,
          p_NEW_PRICING_ATTRIBUTE30             => l_pricing_history_rec.new_pricing_attribute30,
          p_OLD_PRICING_ATTRIBUTE31             => l_pricing_history_rec.old_pricing_attribute31,
          p_NEW_PRICING_ATTRIBUTE31             => l_pricing_history_rec.new_pricing_attribute31,
          p_OLD_PRICING_ATTRIBUTE32             => l_pricing_history_rec.old_pricing_attribute32,
          p_NEW_PRICING_ATTRIBUTE32             => l_pricing_history_rec.new_pricing_attribute32,
          p_OLD_PRICING_ATTRIBUTE33             => l_pricing_history_rec.old_pricing_attribute33,
          p_NEW_PRICING_ATTRIBUTE33             => l_pricing_history_rec.new_pricing_attribute33,
          p_OLD_PRICING_ATTRIBUTE34             => l_pricing_history_rec.old_pricing_attribute34,
          p_NEW_PRICING_ATTRIBUTE34             => l_pricing_history_rec.new_pricing_attribute34,
          p_OLD_PRICING_ATTRIBUTE35             => l_pricing_history_rec.old_pricing_attribute35,
          p_NEW_PRICING_ATTRIBUTE35             => l_pricing_history_rec.new_pricing_attribute35,
          p_OLD_PRICING_ATTRIBUTE36             => l_pricing_history_rec.old_pricing_attribute36,
          p_NEW_PRICING_ATTRIBUTE36             => l_pricing_history_rec.new_pricing_attribute36,
          p_OLD_PRICING_ATTRIBUTE37             => l_pricing_history_rec.old_pricing_attribute37,
          p_NEW_PRICING_ATTRIBUTE37             => l_pricing_history_rec.new_pricing_attribute37,
          p_OLD_PRICING_ATTRIBUTE38             => l_pricing_history_rec.old_pricing_attribute38,
          p_NEW_PRICING_ATTRIBUTE38             => l_pricing_history_rec.new_pricing_attribute38,
          p_OLD_PRICING_ATTRIBUTE39             => l_pricing_history_rec.old_pricing_attribute39,
          p_NEW_PRICING_ATTRIBUTE39             => l_pricing_history_rec.new_pricing_attribute39,
          p_OLD_PRICING_ATTRIBUTE40             => l_pricing_history_rec.old_pricing_attribute40,
          p_NEW_PRICING_ATTRIBUTE40             => l_pricing_history_rec.new_pricing_attribute40,
          p_OLD_PRICING_ATTRIBUTE41             => l_pricing_history_rec.old_pricing_attribute41,
          p_NEW_PRICING_ATTRIBUTE41             => l_pricing_history_rec.new_pricing_attribute41,
          p_OLD_PRICING_ATTRIBUTE42             => l_pricing_history_rec.old_pricing_attribute42,
          p_NEW_PRICING_ATTRIBUTE42             => l_pricing_history_rec.new_pricing_attribute42,
          p_OLD_PRICING_ATTRIBUTE43             => l_pricing_history_rec.old_pricing_attribute43,
          p_NEW_PRICING_ATTRIBUTE43             => l_pricing_history_rec.new_pricing_attribute43,
          p_OLD_PRICING_ATTRIBUTE44             => l_pricing_history_rec.old_pricing_attribute44,
          p_NEW_PRICING_ATTRIBUTE44             => l_pricing_history_rec.new_pricing_attribute44,
          p_OLD_PRICING_ATTRIBUTE45             => l_pricing_history_rec.old_pricing_attribute45,
          p_NEW_PRICING_ATTRIBUTE45             => l_pricing_history_rec.new_pricing_attribute45,
          p_OLD_PRICING_ATTRIBUTE46             => l_pricing_history_rec.old_pricing_attribute46,
          p_NEW_PRICING_ATTRIBUTE46             => l_pricing_history_rec.new_pricing_attribute46,
          p_OLD_PRICING_ATTRIBUTE47             => l_pricing_history_rec.old_pricing_attribute47,
          p_NEW_PRICING_ATTRIBUTE47             => l_pricing_history_rec.new_pricing_attribute47,
          p_OLD_PRICING_ATTRIBUTE48             => l_pricing_history_rec.old_pricing_attribute48,
          p_NEW_PRICING_ATTRIBUTE48             => l_pricing_history_rec.new_pricing_attribute48,
          p_OLD_PRICING_ATTRIBUTE49             => l_pricing_history_rec.old_pricing_attribute49,
          p_NEW_PRICING_ATTRIBUTE49             => l_pricing_history_rec.new_pricing_attribute49,
          p_OLD_PRICING_ATTRIBUTE50             => l_pricing_history_rec.old_pricing_attribute50,
          p_NEW_PRICING_ATTRIBUTE50             => l_pricing_history_rec.new_pricing_attribute50,
          p_OLD_PRICING_ATTRIBUTE51             => l_pricing_history_rec.old_pricing_attribute51,
          p_NEW_PRICING_ATTRIBUTE51             => l_pricing_history_rec.new_pricing_attribute51,
          p_OLD_PRICING_ATTRIBUTE52             => l_pricing_history_rec.old_pricing_attribute52,
          p_NEW_PRICING_ATTRIBUTE52             => l_pricing_history_rec.new_pricing_attribute52,
          p_OLD_PRICING_ATTRIBUTE53             => l_pricing_history_rec.old_pricing_attribute53,
          p_NEW_PRICING_ATTRIBUTE53             => l_pricing_history_rec.new_pricing_attribute53,
          p_OLD_PRICING_ATTRIBUTE54             => l_pricing_history_rec.old_pricing_attribute54,
          p_NEW_PRICING_ATTRIBUTE54             => l_pricing_history_rec.new_pricing_attribute54,
          p_OLD_PRICING_ATTRIBUTE55             => l_pricing_history_rec.old_pricing_attribute55,
          p_NEW_PRICING_ATTRIBUTE55             => l_pricing_history_rec.new_pricing_attribute55,
          p_OLD_PRICING_ATTRIBUTE56             => l_pricing_history_rec.old_pricing_attribute56,
          p_NEW_PRICING_ATTRIBUTE56             => l_pricing_history_rec.new_pricing_attribute56,
          p_OLD_PRICING_ATTRIBUTE57             => l_pricing_history_rec.old_pricing_attribute57,
          p_NEW_PRICING_ATTRIBUTE57             => l_pricing_history_rec.new_pricing_attribute57,
          p_OLD_PRICING_ATTRIBUTE58             => l_pricing_history_rec.old_pricing_attribute58,
          p_NEW_PRICING_ATTRIBUTE58             => l_pricing_history_rec.new_pricing_attribute58,
          p_OLD_PRICING_ATTRIBUTE59             => l_pricing_history_rec.old_pricing_attribute59,
          p_NEW_PRICING_ATTRIBUTE59             => l_pricing_history_rec.new_pricing_attribute59,
          p_OLD_PRICING_ATTRIBUTE60             => l_pricing_history_rec.old_pricing_attribute60,
          p_NEW_PRICING_ATTRIBUTE60             => l_pricing_history_rec.new_pricing_attribute60,
          p_OLD_PRICING_ATTRIBUTE61             => l_pricing_history_rec.old_pricing_attribute61,
          p_NEW_PRICING_ATTRIBUTE61             => l_pricing_history_rec.new_pricing_attribute61,
          p_OLD_PRICING_ATTRIBUTE62             => l_pricing_history_rec.old_pricing_attribute62,
          p_NEW_PRICING_ATTRIBUTE62             => l_pricing_history_rec.new_pricing_attribute62,
          p_OLD_PRICING_ATTRIBUTE63             => l_pricing_history_rec.old_pricing_attribute63,
          p_NEW_PRICING_ATTRIBUTE63             => l_pricing_history_rec.new_pricing_attribute63,
          p_OLD_PRICING_ATTRIBUTE64             => l_pricing_history_rec.old_pricing_attribute64,
          p_NEW_PRICING_ATTRIBUTE64             => l_pricing_history_rec.new_pricing_attribute64,
          p_OLD_PRICING_ATTRIBUTE65             => l_pricing_history_rec.old_pricing_attribute65,
          p_NEW_PRICING_ATTRIBUTE65             => l_pricing_history_rec.new_pricing_attribute65,
          p_OLD_PRICING_ATTRIBUTE66             => l_pricing_history_rec.old_pricing_attribute66,
          p_NEW_PRICING_ATTRIBUTE66             => l_pricing_history_rec.new_pricing_attribute66,
          p_OLD_PRICING_ATTRIBUTE67             => l_pricing_history_rec.old_pricing_attribute67,
          p_NEW_PRICING_ATTRIBUTE67             => l_pricing_history_rec.new_pricing_attribute67,
          p_OLD_PRICING_ATTRIBUTE68             => l_pricing_history_rec.old_pricing_attribute68,
          p_NEW_PRICING_ATTRIBUTE68             => l_pricing_history_rec.new_pricing_attribute68,
          p_OLD_PRICING_ATTRIBUTE69             => l_pricing_history_rec.old_pricing_attribute69,
          p_NEW_PRICING_ATTRIBUTE69             => l_pricing_history_rec.new_pricing_attribute69,
          p_OLD_PRICING_ATTRIBUTE70             => l_pricing_history_rec.old_pricing_attribute70,
          p_NEW_PRICING_ATTRIBUTE70             => l_pricing_history_rec.new_pricing_attribute70,
          p_OLD_PRICING_ATTRIBUTE71             => l_pricing_history_rec.old_pricing_attribute71,
          p_NEW_PRICING_ATTRIBUTE71             => l_pricing_history_rec.new_pricing_attribute71,
          p_OLD_PRICING_ATTRIBUTE72             => l_pricing_history_rec.old_pricing_attribute72,
          p_NEW_PRICING_ATTRIBUTE72             => l_pricing_history_rec.new_pricing_attribute72,
          p_OLD_PRICING_ATTRIBUTE73             => l_pricing_history_rec.old_pricing_attribute73,
          p_NEW_PRICING_ATTRIBUTE73             => l_pricing_history_rec.new_pricing_attribute73,
          p_OLD_PRICING_ATTRIBUTE74             => l_pricing_history_rec.old_pricing_attribute74,
          p_NEW_PRICING_ATTRIBUTE74             => l_pricing_history_rec.new_pricing_attribute74,
          p_OLD_PRICING_ATTRIBUTE75             => l_pricing_history_rec.old_pricing_attribute75,
          p_NEW_PRICING_ATTRIBUTE75             => l_pricing_history_rec.new_pricing_attribute75,
          p_OLD_PRICING_ATTRIBUTE76             => l_pricing_history_rec.old_pricing_attribute76,
          p_NEW_PRICING_ATTRIBUTE76             => l_pricing_history_rec.new_pricing_attribute76,
          p_OLD_PRICING_ATTRIBUTE77             => l_pricing_history_rec.old_pricing_attribute77,
          p_NEW_PRICING_ATTRIBUTE77             => l_pricing_history_rec.new_pricing_attribute77,
          p_OLD_PRICING_ATTRIBUTE78             => l_pricing_history_rec.old_pricing_attribute78,
          p_NEW_PRICING_ATTRIBUTE78             => l_pricing_history_rec.new_pricing_attribute78,
          p_OLD_PRICING_ATTRIBUTE79             => l_pricing_history_rec.old_pricing_attribute79,
          p_NEW_PRICING_ATTRIBUTE79             => l_pricing_history_rec.new_pricing_attribute79,
          p_OLD_PRICING_ATTRIBUTE80             => l_pricing_history_rec.old_pricing_attribute80,
          p_NEW_PRICING_ATTRIBUTE80             => l_pricing_history_rec.new_pricing_attribute80,
          p_OLD_PRICING_ATTRIBUTE81             => l_pricing_history_rec.old_pricing_attribute81,
          p_NEW_PRICING_ATTRIBUTE81             => l_pricing_history_rec.new_pricing_attribute81,
          p_OLD_PRICING_ATTRIBUTE82             => l_pricing_history_rec.old_pricing_attribute82,
          p_NEW_PRICING_ATTRIBUTE82             => l_pricing_history_rec.new_pricing_attribute82,
          p_OLD_PRICING_ATTRIBUTE83             => l_pricing_history_rec.old_pricing_attribute83,
          p_NEW_PRICING_ATTRIBUTE83             => l_pricing_history_rec.new_pricing_attribute83,
          p_OLD_PRICING_ATTRIBUTE84             => l_pricing_history_rec.old_pricing_attribute84,
          p_NEW_PRICING_ATTRIBUTE84             => l_pricing_history_rec.new_pricing_attribute84,
          p_OLD_PRICING_ATTRIBUTE85             => l_pricing_history_rec.old_pricing_attribute85,
          p_NEW_PRICING_ATTRIBUTE85             => l_pricing_history_rec.new_pricing_attribute85,
          p_OLD_PRICING_ATTRIBUTE86             => l_pricing_history_rec.old_pricing_attribute86,
          p_NEW_PRICING_ATTRIBUTE86             => l_pricing_history_rec.new_pricing_attribute86,
          p_OLD_PRICING_ATTRIBUTE87             => l_pricing_history_rec.old_pricing_attribute87,
          p_NEW_PRICING_ATTRIBUTE87             => l_pricing_history_rec.new_pricing_attribute87,
          p_OLD_PRICING_ATTRIBUTE88             => l_pricing_history_rec.old_pricing_attribute88,
          p_NEW_PRICING_ATTRIBUTE88             => l_pricing_history_rec.new_pricing_attribute88,
          p_OLD_PRICING_ATTRIBUTE89             => l_pricing_history_rec.old_pricing_attribute89,
          p_NEW_PRICING_ATTRIBUTE89             => l_pricing_history_rec.new_pricing_attribute89,
          p_OLD_PRICING_ATTRIBUTE90             => l_pricing_history_rec.old_pricing_attribute90,
          p_NEW_PRICING_ATTRIBUTE90             => l_pricing_history_rec.new_pricing_attribute90,
          p_OLD_PRICING_ATTRIBUTE91             => l_pricing_history_rec.old_pricing_attribute91,
          p_NEW_PRICING_ATTRIBUTE91             => l_pricing_history_rec.new_pricing_attribute91,
          p_OLD_PRICING_ATTRIBUTE92             => l_pricing_history_rec.old_pricing_attribute92,
          p_NEW_PRICING_ATTRIBUTE92             => l_pricing_history_rec.new_pricing_attribute92,
          p_OLD_PRICING_ATTRIBUTE93             => l_pricing_history_rec.old_pricing_attribute93,
          p_NEW_PRICING_ATTRIBUTE93             => l_pricing_history_rec.new_pricing_attribute93,
          p_OLD_PRICING_ATTRIBUTE94             => l_pricing_history_rec.old_pricing_attribute94,
          p_NEW_PRICING_ATTRIBUTE94             => l_pricing_history_rec.new_pricing_attribute94,
          p_OLD_PRICING_ATTRIBUTE95             => l_pricing_history_rec.old_pricing_attribute95,
          p_NEW_PRICING_ATTRIBUTE95             => l_pricing_history_rec.new_pricing_attribute95,
          p_OLD_PRICING_ATTRIBUTE96             => l_pricing_history_rec.old_pricing_attribute96,
          p_NEW_PRICING_ATTRIBUTE96             => l_pricing_history_rec.new_pricing_attribute96,
          p_OLD_PRICING_ATTRIBUTE97             => l_pricing_history_rec.old_pricing_attribute97,
          p_NEW_PRICING_ATTRIBUTE97             => l_pricing_history_rec.new_pricing_attribute97,
          p_OLD_PRICING_ATTRIBUTE98             => l_pricing_history_rec.old_pricing_attribute98,
          p_NEW_PRICING_ATTRIBUTE98             => l_pricing_history_rec.new_pricing_attribute98,
          p_OLD_PRICING_ATTRIBUTE99             => l_pricing_history_rec.old_pricing_attribute99,
          p_NEW_PRICING_ATTRIBUTE99             => l_pricing_history_rec.new_pricing_attribute99,
          p_OLD_PRICING_ATTRIBUTE100            => l_pricing_history_rec.old_pricing_attribute100,
          p_NEW_PRICING_ATTRIBUTE100            => l_pricing_history_rec.new_pricing_attribute100,
          p_OLD_ACTIVE_START_DATE               => l_pricing_history_rec.old_active_start_date,
          p_NEW_ACTIVE_START_DATE               => l_pricing_history_rec.new_active_start_date,
          p_OLD_ACTIVE_END_DATE                 => l_pricing_history_rec.old_active_end_date,
          p_NEW_ACTIVE_END_DATE                 => l_pricing_history_rec.new_active_end_date,
          p_OLD_CONTEXT                         => l_pricing_history_rec.old_context,
          p_NEW_CONTEXT                         => l_pricing_history_rec.new_context,
          p_OLD_ATTRIBUTE1                      => l_pricing_history_rec.old_ATTRIBUTE1,
          p_NEW_ATTRIBUTE1                      => l_pricing_history_rec.new_ATTRIBUTE1,
          p_OLD_ATTRIBUTE2                      => l_pricing_history_rec.old_ATTRIBUTE2,
          p_NEW_ATTRIBUTE2                      => l_pricing_history_rec.new_ATTRIBUTE2,
          p_OLD_ATTRIBUTE3                      => l_pricing_history_rec.old_ATTRIBUTE3,
          p_NEW_ATTRIBUTE3                      => l_pricing_history_rec.new_ATTRIBUTE3,
          p_OLD_ATTRIBUTE4                      => l_pricing_history_rec.old_ATTRIBUTE4,
          p_NEW_ATTRIBUTE4                      => l_pricing_history_rec.new_ATTRIBUTE4,
          p_OLD_ATTRIBUTE5                      => l_pricing_history_rec.old_ATTRIBUTE5,
          p_NEW_ATTRIBUTE5                      => l_pricing_history_rec.new_ATTRIBUTE5,
          p_OLD_ATTRIBUTE6                      => l_pricing_history_rec.old_ATTRIBUTE6,
          p_NEW_ATTRIBUTE6                      => l_pricing_history_rec.new_ATTRIBUTE6,
          p_OLD_ATTRIBUTE7                      => l_pricing_history_rec.old_ATTRIBUTE7,
          p_NEW_ATTRIBUTE7                      => l_pricing_history_rec.new_ATTRIBUTE7,
          p_OLD_ATTRIBUTE8                      => l_pricing_history_rec.old_ATTRIBUTE8,
          p_NEW_ATTRIBUTE8                      => l_pricing_history_rec.new_ATTRIBUTE8,
          p_OLD_ATTRIBUTE9                      => l_pricing_history_rec.old_ATTRIBUTE9,
          p_NEW_ATTRIBUTE9                      => l_pricing_history_rec.new_ATTRIBUTE9,
          p_OLD_ATTRIBUTE10                     => l_pricing_history_rec.old_ATTRIBUTE10,
          p_NEW_ATTRIBUTE10                     => l_pricing_history_rec.new_ATTRIBUTE10,
          p_OLD_ATTRIBUTE11                     => l_pricing_history_rec.old_ATTRIBUTE11,
          p_NEW_ATTRIBUTE11                     => l_pricing_history_rec.new_ATTRIBUTE11,
          p_OLD_ATTRIBUTE12                     => l_pricing_history_rec.old_ATTRIBUTE12,
          p_NEW_ATTRIBUTE12                     => l_pricing_history_rec.new_ATTRIBUTE12,
          p_OLD_ATTRIBUTE13                     => l_pricing_history_rec.old_ATTRIBUTE13,
          p_NEW_ATTRIBUTE13                     => l_pricing_history_rec.new_ATTRIBUTE13,
          p_OLD_ATTRIBUTE14                     => l_pricing_history_rec.old_ATTRIBUTE14,
          p_NEW_ATTRIBUTE14                     => l_pricing_history_rec.new_ATTRIBUTE14,
          p_OLD_ATTRIBUTE15                     => l_pricing_history_rec.old_ATTRIBUTE15,
          p_NEW_ATTRIBUTE15                     => l_pricing_history_rec.new_ATTRIBUTE15,
          p_FULL_DUMP_FLAG                      => l_dump_frequency_flag,
          p_CREATED_BY                          => fnd_global.user_id,
          p_CREATION_DATE                       => sysdate,
          p_LAST_UPDATED_BY                     => fnd_global.user_id,
          p_LAST_UPDATE_DATE                    => sysdate,
          p_LAST_UPDATE_LOGIN                   => fnd_global.user_id,
          p_OBJECT_VERSION_NUMBER               => 1);

        END IF;
      END;
      -- End of modification for Bug#2547034 on 09/20/02 - rtalluri
      -- End of API body

      -- Standard check of p_commit.
      IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is  get message info.
      FND_MSG_PUB.Count_And_Get
            (p_count       =>       x_msg_count ,
               p_data       =>       x_msg_data
            );


EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO update_pricing_attribs;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (   p_count               =>      x_msg_count,
                    p_data                =>      x_msg_data
                 );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO update_pricing_attribs;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
                   (p_count    =>      x_msg_count,
                    p_data     =>      x_msg_data
                    );

      WHEN OTHERS THEN
            ROLLBACK TO  update_pricing_attribs;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                    FND_MSG_PUB.Add_Exc_Msg
                         (g_pkg_name,
                          l_api_name
                         );
            END IF;

            FND_MSG_PUB.Count_And_Get
                    (p_count   =>      x_msg_count,
                     p_data    =>      x_msg_data
                     );

END update_pricing_attribs;



/*------------------------------------------------------*/
/* procedure name: expire_pricing_attribs               */
/* description :  Expires the existing pricing          */
/*                attributes for an item instance       */
/*                                                      */
/*------------------------------------------------------*/


PROCEDURE expire_pricing_attribs
 (
      p_api_version                 IN      NUMBER
     ,p_commit                      IN      VARCHAR2
     ,p_init_msg_list               IN      VARCHAR2
     ,p_validation_level            IN      NUMBER
     ,p_pricing_attribs_rec         IN      csi_datastructures_pub.pricing_attribs_rec
     ,p_txn_rec                     IN  OUT NOCOPY csi_datastructures_pub.transaction_rec
     ,x_return_status                   OUT NOCOPY VARCHAR2
     ,x_msg_count                       OUT NOCOPY NUMBER
     ,x_msg_data                        OUT NOCOPY VARCHAR2
 )

IS
      l_api_name                  CONSTANT VARCHAR2(30)   := 'EXPIRE_PRICING_ATTRIBS';
      l_api_version               CONSTANT NUMBER            := 1.0;
      l_debug_level                        NUMBER;
      l_msg_index                          NUMBER;
      l_msg_count                          NUMBER;
      l_pricing_attribs_rec                csi_datastructures_pub.pricing_attribs_rec;
      l_object_version_number              NUMBER;
BEGIN

     -- Standard Start of API savepoint
     SAVEPOINT      expire_pricing_attribs;

          -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name ,
                                        g_pkg_name)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Check the profile option debug_level for debug message reporting
    l_debug_level:=fnd_profile.value('CSI_DEBUG_LEVEL');

    -- If debug_level = 1 then dump the procedure name
    IF (l_debug_level > 0) THEN
        csi_gen_utility_pvt.put_line( 'expire_pricing_attribs');
    END IF;

    -- If the debug level = 2 then dump all the parameters values.
    IF (l_debug_level > 1) THEN
       csi_gen_utility_pvt.put_line(
                             p_api_version   ||'-'
                          || p_commit        ||'-'
                          || p_init_msg_list ||'-'
                          || p_validation_level);
      -- Dump pricing attribute rec
      csi_gen_utility_pvt.dump_pricing_attribs_rec(p_pricing_attribs_rec);
      -- Dump txn_rec
      csi_gen_utility_pvt.dump_txn_rec(p_txn_rec);
    END IF;


    -- Start API body

    -- Validate pricing_attribute_id
    IF NOT(csi_pricing_attrib_vld_pvt.Val_and_get_pri_att_id
         (p_pricing_attribs_rec.pricing_attribute_id,
           l_pricing_attribs_rec)) THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

     l_pricing_attribs_rec.pricing_attribute_id  :=  p_pricing_attribs_rec.pricing_attribute_id ;
     l_pricing_attribs_rec.instance_id           :=  FND_API.G_MISS_NUM;
     l_pricing_attribs_rec.active_end_date       :=  SYSDATE;
     l_pricing_attribs_rec.pricing_context       :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute1    :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute2    :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute3    :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute4    :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute5    :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute6    :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute7    :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute8    :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute9    :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute10   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute11   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute12   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute13   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute14   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute15   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute16   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute17   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute18   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute19   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute20   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute21   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute22   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute23   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute24   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute25   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute26   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute27   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute28   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute29   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute30   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute31   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute32   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute33   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute34   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute35   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute36   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute37   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute38   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute39   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute40   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute41   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute42   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute43   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute44   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute45   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute46   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute47   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute48   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute49   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute50   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute51   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute52   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute53   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute54   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute55   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute56   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute57   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute58   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute59   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute60   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute61   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute62   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute63   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute64   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute65   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute66   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute67   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute68   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute69   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute70   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute71   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute72   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute73   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute74   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute75   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute76   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute77   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute78   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute79   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute80   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute81   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute82   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute83   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute84   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute85   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute86   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute87   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute88   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute89   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute90   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute91   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute92   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute93   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute94   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute95   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute96   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute97   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute98   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute99   :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.pricing_attribute100  :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.context               :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute1            :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute2            :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute3            :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute4            :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute5            :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute6            :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute7            :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute8            :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute9            :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute10           :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute11           :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute12           :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute13           :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute14           :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.attribute15           :=  FND_API.G_MISS_CHAR;
     l_pricing_attribs_rec.object_version_number := p_pricing_attribs_rec.object_version_number ;

     g_expire_pric_flag     := 'Y';
     csi_pricing_attribs_pvt.update_pricing_attribs
              ( p_api_version          => p_api_version
               ,p_commit               => fnd_api.g_false
               ,p_init_msg_list        => p_init_msg_list
               ,p_validation_level     => p_validation_level
               ,p_pricing_attribs_rec  => l_pricing_attribs_rec
               ,p_txn_rec              => p_txn_rec
               ,x_return_status        => x_return_status
               ,x_msg_count            =>  x_msg_count
               ,x_msg_data             =>  x_msg_data
               );

     g_expire_pric_flag     := 'N';


                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   l_msg_index := 1;
                   l_msg_count := x_msg_count;
                   WHILE l_msg_count > 0 LOOP
                       x_msg_data := FND_MSG_PUB.GET
                          (  l_msg_index,
                               FND_API.G_FALSE      );

                       csi_gen_utility_pvt.put_line('message data = '||x_msg_data);
                       l_msg_index := l_msg_index + 1;
                       l_msg_count := l_msg_count - 1;
                    END LOOP;
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

     -- End of API body

     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
     END IF;

      -- Standard call to get message count and if count is  get message info.
      FND_MSG_PUB.Count_And_Get
      (p_count       =>       x_msg_count ,
       p_data       =>       x_msg_data
       );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO expire_pricing_attribs;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
                    ( p_count   =>      x_msg_count,
                      p_data    =>      x_msg_data
                    );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO expire_pricing_attribs;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
                   (p_count     =>      x_msg_count,
                    p_data      =>      x_msg_data
                   );

      WHEN OTHERS THEN
            ROLLBACK TO  expire_pricing_attribs;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF       FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                    FND_MSG_PUB.Add_Exc_Msg
                       ( g_pkg_name,
                         l_api_name
                        );
            END IF;

            FND_MSG_PUB.Count_And_Get
                    (  p_count  =>      x_msg_count,
                       p_data   =>      x_msg_data
                    );

END expire_pricing_attribs;


END csi_pricing_attribs_pvt;

/
