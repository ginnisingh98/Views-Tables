--------------------------------------------------------
--  DDL for Package OE_OE_FORM_LINE_PATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OE_FORM_LINE_PATTR" AUTHID CURRENT_USER AS
/* $Header: OEXFLPAS.pls 120.0 2005/05/31 22:28:32 appldev noship $ */

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id				 in  NUMBER
,   p_line_id					 in  NUMBER
, x_attribute1 OUT NOCOPY VARCHAR2
, x_attribute10 OUT NOCOPY VARCHAR2
, x_attribute11 OUT NOCOPY VARCHAR2
, x_attribute12 OUT NOCOPY VARCHAR2
, x_attribute13 OUT NOCOPY VARCHAR2
, x_attribute14 OUT NOCOPY VARCHAR2
, x_attribute15 OUT NOCOPY VARCHAR2
, x_attribute2 OUT NOCOPY VARCHAR2
, x_attribute3 OUT NOCOPY VARCHAR2
, x_attribute4 OUT NOCOPY VARCHAR2
, x_attribute5 OUT NOCOPY VARCHAR2
, x_attribute6 OUT NOCOPY VARCHAR2
, x_attribute7 OUT NOCOPY VARCHAR2
, x_attribute8 OUT NOCOPY VARCHAR2
, x_attribute9 OUT NOCOPY VARCHAR2
, x_flex_title OUT NOCOPY VARCHAR2
, x_context OUT NOCOPY VARCHAR2
, x_header_id OUT NOCOPY NUMBER
, x_line_id OUT NOCOPY NUMBER
, x_order_price_attrib_id OUT NOCOPY NUMBER
, x_pricing_attribute1 OUT NOCOPY VARCHAR2
, x_pricing_attribute10 OUT NOCOPY VARCHAR2
, x_pricing_attribute11 OUT NOCOPY VARCHAR2
, x_pricing_attribute12 OUT NOCOPY VARCHAR2
, x_pricing_attribute13 OUT NOCOPY VARCHAR2
, x_pricing_attribute14 OUT NOCOPY VARCHAR2
, x_pricing_attribute15 OUT NOCOPY VARCHAR2
, x_pricing_attribute2 OUT NOCOPY VARCHAR2
, x_pricing_attribute3 OUT NOCOPY VARCHAR2
, x_pricing_attribute4 OUT NOCOPY VARCHAR2
, x_pricing_attribute5 OUT NOCOPY VARCHAR2
, x_pricing_attribute6 OUT NOCOPY VARCHAR2
, x_pricing_attribute7 OUT NOCOPY VARCHAR2
, x_pricing_attribute8 OUT NOCOPY VARCHAR2
, x_pricing_attribute9 OUT NOCOPY VARCHAR2
, x_pricing_attribute16 OUT NOCOPY VARCHAR2
, x_pricing_attribute17 OUT NOCOPY VARCHAR2
, x_pricing_attribute18 OUT NOCOPY VARCHAR2
, x_pricing_attribute19 OUT NOCOPY VARCHAR2
, x_pricing_attribute20 OUT NOCOPY VARCHAR2
, x_pricing_attribute21 OUT NOCOPY VARCHAR2
, x_pricing_attribute22 OUT NOCOPY VARCHAR2
, x_pricing_attribute23 OUT NOCOPY VARCHAR2
, x_pricing_attribute24 OUT NOCOPY VARCHAR2
, x_pricing_attribute25 OUT NOCOPY VARCHAR2
, x_pricing_attribute26 OUT NOCOPY VARCHAR2
, x_pricing_attribute27 OUT NOCOPY VARCHAR2
, x_pricing_attribute28 OUT NOCOPY VARCHAR2
, x_pricing_attribute29 OUT NOCOPY VARCHAR2
, x_pricing_attribute30 OUT NOCOPY VARCHAR2
, x_pricing_attribute31 OUT NOCOPY VARCHAR2
, x_pricing_attribute32 OUT NOCOPY VARCHAR2
, x_pricing_attribute33 OUT NOCOPY VARCHAR2
, x_pricing_attribute34 OUT NOCOPY VARCHAR2
, x_pricing_attribute35 OUT NOCOPY VARCHAR2
, x_pricing_attribute36 OUT NOCOPY VARCHAR2
, x_pricing_attribute37 OUT NOCOPY VARCHAR2
, x_pricing_attribute38 OUT NOCOPY VARCHAR2
, x_pricing_attribute39 OUT NOCOPY VARCHAR2
, x_pricing_attribute40 OUT NOCOPY VARCHAR2
, x_pricing_attribute41 OUT NOCOPY VARCHAR2
, x_pricing_attribute42 OUT NOCOPY VARCHAR2
, x_pricing_attribute43 OUT NOCOPY VARCHAR2
, x_pricing_attribute44 OUT NOCOPY VARCHAR2
, x_pricing_attribute45 OUT NOCOPY VARCHAR2
, x_pricing_attribute46 OUT NOCOPY VARCHAR2
, x_pricing_attribute47 OUT NOCOPY VARCHAR2
, x_pricing_attribute48 OUT NOCOPY VARCHAR2
, x_pricing_attribute49 OUT NOCOPY VARCHAR2
, x_pricing_attribute50 OUT NOCOPY VARCHAR2
, x_pricing_attribute51 OUT NOCOPY VARCHAR2
, x_pricing_attribute52 OUT NOCOPY VARCHAR2
, x_pricing_attribute53 OUT NOCOPY VARCHAR2
, x_pricing_attribute54 OUT NOCOPY VARCHAR2
, x_pricing_attribute55 OUT NOCOPY VARCHAR2
, x_pricing_attribute56 OUT NOCOPY VARCHAR2
, x_pricing_attribute57 OUT NOCOPY VARCHAR2
, x_pricing_attribute58 OUT NOCOPY VARCHAR2
, x_pricing_attribute59 OUT NOCOPY VARCHAR2
, x_pricing_attribute60 OUT NOCOPY VARCHAR2
, x_pricing_attribute61 OUT NOCOPY VARCHAR2
, x_pricing_attribute62 OUT NOCOPY VARCHAR2
, x_pricing_attribute63 OUT NOCOPY VARCHAR2
, x_pricing_attribute64 OUT NOCOPY VARCHAR2
, x_pricing_attribute65 OUT NOCOPY VARCHAR2
, x_pricing_attribute66 OUT NOCOPY VARCHAR2
, x_pricing_attribute67 OUT NOCOPY VARCHAR2
, x_pricing_attribute68 OUT NOCOPY VARCHAR2
, x_pricing_attribute69 OUT NOCOPY VARCHAR2
, x_pricing_attribute70 OUT NOCOPY VARCHAR2
, x_pricing_attribute71 OUT NOCOPY VARCHAR2
, x_pricing_attribute72 OUT NOCOPY VARCHAR2
, x_pricing_attribute73 OUT NOCOPY VARCHAR2
, x_pricing_attribute74 OUT NOCOPY VARCHAR2
, x_pricing_attribute75 OUT NOCOPY VARCHAR2
, x_pricing_attribute76 OUT NOCOPY VARCHAR2
, x_pricing_attribute77 OUT NOCOPY VARCHAR2
, x_pricing_attribute78 OUT NOCOPY VARCHAR2
, x_pricing_attribute79 OUT NOCOPY VARCHAR2
, x_pricing_attribute80 OUT NOCOPY VARCHAR2
, x_pricing_attribute81 OUT NOCOPY VARCHAR2
, x_pricing_attribute82 OUT NOCOPY VARCHAR2
, x_pricing_attribute83 OUT NOCOPY VARCHAR2
, x_pricing_attribute84 OUT NOCOPY VARCHAR2
, x_pricing_attribute85 OUT NOCOPY VARCHAR2
, x_pricing_attribute86 OUT NOCOPY VARCHAR2
, x_pricing_attribute87 OUT NOCOPY VARCHAR2
, x_pricing_attribute88 OUT NOCOPY VARCHAR2
, x_pricing_attribute89 OUT NOCOPY VARCHAR2
, x_pricing_attribute90 OUT NOCOPY VARCHAR2
, x_pricing_attribute91 OUT NOCOPY VARCHAR2
, x_pricing_attribute92 OUT NOCOPY VARCHAR2
, x_pricing_attribute93 OUT NOCOPY VARCHAR2
, x_pricing_attribute94 OUT NOCOPY VARCHAR2
, x_pricing_attribute95 OUT NOCOPY VARCHAR2
, x_pricing_attribute96 OUT NOCOPY VARCHAR2
, x_pricing_attribute97 OUT NOCOPY VARCHAR2
, x_pricing_attribute98 OUT NOCOPY VARCHAR2
, x_pricing_attribute99 OUT NOCOPY VARCHAR2
, x_pricing_attribute100 OUT NOCOPY VARCHAR2
, x_pricing_context OUT NOCOPY VARCHAR2
, x_override_flag OUT NOCOPY VARCHAR2
, x_creation_date OUT NOCOPY DATE
);

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id				 in  NUMBER
,   p_line_id					 in  NUMBER
, x_attribute1 OUT NOCOPY VARCHAR2
, x_attribute10 OUT NOCOPY VARCHAR2
, x_attribute11 OUT NOCOPY VARCHAR2
, x_attribute12 OUT NOCOPY VARCHAR2
, x_attribute13 OUT NOCOPY VARCHAR2
, x_attribute14 OUT NOCOPY VARCHAR2
, x_attribute15 OUT NOCOPY VARCHAR2
, x_attribute2 OUT NOCOPY VARCHAR2
, x_attribute3 OUT NOCOPY VARCHAR2
, x_attribute4 OUT NOCOPY VARCHAR2
, x_attribute5 OUT NOCOPY VARCHAR2
, x_attribute6 OUT NOCOPY VARCHAR2
, x_attribute7 OUT NOCOPY VARCHAR2
, x_attribute8 OUT NOCOPY VARCHAR2
, x_attribute9 OUT NOCOPY VARCHAR2
, x_flex_title OUT NOCOPY VARCHAR2
, x_context OUT NOCOPY VARCHAR2
, x_header_id OUT NOCOPY NUMBER
, x_line_id OUT NOCOPY NUMBER
, x_order_price_attrib_id OUT NOCOPY NUMBER
, x_pricing_attribute1 OUT NOCOPY VARCHAR2
, x_pricing_attribute2 OUT NOCOPY VARCHAR2
, x_pricing_attribute3 OUT NOCOPY VARCHAR2
, x_pricing_context OUT NOCOPY VARCHAR2
, x_override_flag OUT NOCOPY VARCHAR2
, x_creation_date OUT NOCOPY DATE
);

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id				 in  NUMBER
,   p_line_id					 in  NUMBER
, x_attribute1 OUT NOCOPY VARCHAR2
, x_attribute10 OUT NOCOPY VARCHAR2
, x_attribute11 OUT NOCOPY VARCHAR2
, x_attribute12 OUT NOCOPY VARCHAR2
, x_attribute13 OUT NOCOPY VARCHAR2
, x_attribute14 OUT NOCOPY VARCHAR2
, x_attribute15 OUT NOCOPY VARCHAR2
, x_attribute2 OUT NOCOPY VARCHAR2
, x_attribute3 OUT NOCOPY VARCHAR2
, x_attribute4 OUT NOCOPY VARCHAR2
, x_attribute5 OUT NOCOPY VARCHAR2
, x_attribute6 OUT NOCOPY VARCHAR2
, x_attribute7 OUT NOCOPY VARCHAR2
, x_attribute8 OUT NOCOPY VARCHAR2
, x_attribute9 OUT NOCOPY VARCHAR2
, x_flex_title OUT NOCOPY VARCHAR2
, x_context OUT NOCOPY VARCHAR2
, x_header_id OUT NOCOPY NUMBER
, x_line_id OUT NOCOPY NUMBER
, x_order_price_attrib_id OUT NOCOPY NUMBER
, x_pricing_attribute1 OUT NOCOPY VARCHAR2
, x_pricing_attribute10 OUT NOCOPY VARCHAR2
, x_pricing_attribute11 OUT NOCOPY VARCHAR2
, x_pricing_attribute12 OUT NOCOPY VARCHAR2
, x_pricing_attribute13 OUT NOCOPY VARCHAR2
, x_pricing_attribute14 OUT NOCOPY VARCHAR2
, x_pricing_attribute15 OUT NOCOPY VARCHAR2
, x_pricing_attribute2 OUT NOCOPY VARCHAR2
, x_pricing_attribute3 OUT NOCOPY VARCHAR2
, x_pricing_attribute4 OUT NOCOPY VARCHAR2
, x_pricing_attribute5 OUT NOCOPY VARCHAR2
, x_pricing_attribute6 OUT NOCOPY VARCHAR2
, x_pricing_attribute7 OUT NOCOPY VARCHAR2
, x_pricing_attribute8 OUT NOCOPY VARCHAR2
, x_pricing_attribute9 OUT NOCOPY VARCHAR2
, x_pricing_attribute16 OUT NOCOPY VARCHAR2
, x_pricing_attribute17 OUT NOCOPY VARCHAR2
, x_pricing_attribute18 OUT NOCOPY VARCHAR2
, x_pricing_attribute19 OUT NOCOPY VARCHAR2
, x_pricing_attribute20 OUT NOCOPY VARCHAR2
, x_pricing_attribute21 OUT NOCOPY VARCHAR2
, x_pricing_attribute22 OUT NOCOPY VARCHAR2
, x_pricing_attribute23 OUT NOCOPY VARCHAR2
, x_pricing_attribute24 OUT NOCOPY VARCHAR2
, x_pricing_attribute25 OUT NOCOPY VARCHAR2
, x_pricing_attribute26 OUT NOCOPY VARCHAR2
, x_pricing_attribute27 OUT NOCOPY VARCHAR2
, x_pricing_attribute28 OUT NOCOPY VARCHAR2
, x_pricing_attribute29 OUT NOCOPY VARCHAR2
, x_pricing_attribute30 OUT NOCOPY VARCHAR2
, x_pricing_context OUT NOCOPY VARCHAR2
, x_override_flag OUT NOCOPY VARCHAR2
, x_creation_date OUT NOCOPY DATE
);

PROCEDURE Change_Attributes
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,    p_order_price_attrib_id		 IN NUMBER
,    p_attr_id					 IN NUMBER
,	p_context					 IN VARCHAR2
,    p_attr_value				 IN VARCHAR2
,	p_attribute1				 IN VARCHAR2
,	p_attribute2				 IN VARCHAR2
,	p_attribute3				 IN VARCHAR2
,	p_attribute4				 IN VARCHAR2
,	p_attribute5				 IN VARCHAR2
,	p_attribute6				 IN VARCHAR2
,	p_attribute7				 IN VARCHAR2
,	p_attribute8				 IN VARCHAR2
,	p_attribute9				 IN VARCHAR2
,	p_attribute10				 IN VARCHAR2
,	p_attribute11				 IN VARCHAR2
,	p_attribute12				 IN VARCHAR2
,	p_attribute13				 IN VARCHAR2
,	p_attribute14				 IN VARCHAR2
,	p_attribute15				 IN VARCHAR2
,   p_pricing_attribute1            IN VARCHAR2
,   p_pricing_attribute10           IN VARCHAR2
,   p_pricing_attribute11           IN VARCHAR2
,   p_pricing_attribute12           IN VARCHAR2
,   p_pricing_attribute13           IN VARCHAR2
,   p_pricing_attribute14           IN VARCHAR2
,   p_pricing_attribute15           IN VARCHAR2
,   p_pricing_attribute2            IN VARCHAR2
,   p_pricing_attribute3            IN VARCHAR2
,   p_pricing_attribute4            IN VARCHAR2
,   p_pricing_attribute5            IN VARCHAR2
,   p_pricing_attribute6            IN VARCHAR2
,   p_pricing_attribute7            IN VARCHAR2
,   p_pricing_attribute8            IN VARCHAR2
,   p_pricing_attribute9            IN VARCHAR2
,   p_pricing_attribute16           IN VARCHAR2
,   p_pricing_attribute17           IN VARCHAR2
,   p_pricing_attribute18           IN VARCHAR2
,   p_pricing_attribute19           IN VARCHAR2
,   p_pricing_attribute20           IN VARCHAR2
,   p_pricing_attribute21           IN VARCHAR2
,   p_pricing_attribute22           IN VARCHAR2
,   p_pricing_attribute23           IN VARCHAR2
,   p_pricing_attribute24           IN VARCHAR2
,   p_pricing_attribute25           IN VARCHAR2
,   p_pricing_attribute26           IN VARCHAR2
,   p_pricing_attribute27           IN VARCHAR2
,   p_pricing_attribute28           IN VARCHAR2
,   p_pricing_attribute29           IN VARCHAR2
,   p_pricing_attribute30           IN VARCHAR2
,   p_pricing_attribute31           IN VARCHAR2
,   p_pricing_attribute32           IN VARCHAR2
,   p_pricing_attribute33           IN VARCHAR2
,   p_pricing_attribute34           IN VARCHAR2
,   p_pricing_attribute35           IN VARCHAR2
,   p_pricing_attribute36           IN VARCHAR2
,   p_pricing_attribute37           IN VARCHAR2
,   p_pricing_attribute38           IN VARCHAR2
,   p_pricing_attribute39           IN VARCHAR2
,   p_pricing_attribute40           IN VARCHAR2
,   p_pricing_attribute41           IN VARCHAR2
,   p_pricing_attribute42           IN VARCHAR2
,   p_pricing_attribute43           IN VARCHAR2
,   p_pricing_attribute44           IN VARCHAR2
,   p_pricing_attribute45           IN VARCHAR2
,   p_pricing_attribute46           IN VARCHAR2
,   p_pricing_attribute47           IN VARCHAR2
,   p_pricing_attribute48           IN VARCHAR2
,   p_pricing_attribute49           IN VARCHAR2
,   p_pricing_attribute50           IN VARCHAR2
,   p_pricing_attribute51           IN VARCHAR2
,   p_pricing_attribute52           IN VARCHAR2
,   p_pricing_attribute53           IN VARCHAR2
,   p_pricing_attribute54           IN VARCHAR2
,   p_pricing_attribute55           IN VARCHAR2
,   p_pricing_attribute56           IN VARCHAR2
,   p_pricing_attribute57           IN VARCHAR2
,   p_pricing_attribute58           IN VARCHAR2
,   p_pricing_attribute59           IN VARCHAR2
,   p_pricing_attribute60           IN VARCHAR2
,   p_pricing_attribute61           IN VARCHAR2
,   p_pricing_attribute62           IN VARCHAR2
,   p_pricing_attribute63           IN VARCHAR2
,   p_pricing_attribute64           IN VARCHAR2
,   p_pricing_attribute65           IN VARCHAR2
,   p_pricing_attribute66           IN VARCHAR2
,   p_pricing_attribute67           IN VARCHAR2
,   p_pricing_attribute68           IN VARCHAR2
,   p_pricing_attribute69           IN VARCHAR2
,   p_pricing_attribute70           IN VARCHAR2
,   p_pricing_attribute71           IN VARCHAR2
,   p_pricing_attribute72           IN VARCHAR2
,   p_pricing_attribute73           IN VARCHAR2
,   p_pricing_attribute74           IN VARCHAR2
,   p_pricing_attribute75           IN VARCHAR2
,   p_pricing_attribute76           IN VARCHAR2
,   p_pricing_attribute77           IN VARCHAR2
,   p_pricing_attribute78           IN VARCHAR2
,   p_pricing_attribute79           IN VARCHAR2
,   p_pricing_attribute80           IN VARCHAR2
,   p_pricing_attribute81           IN VARCHAR2
,   p_pricing_attribute82           IN VARCHAR2
,   p_pricing_attribute83           IN VARCHAR2
,   p_pricing_attribute84           IN VARCHAR2
,   p_pricing_attribute85           IN VARCHAR2
,   p_pricing_attribute86           IN VARCHAR2
,   p_pricing_attribute87           IN VARCHAR2
,   p_pricing_attribute88           IN VARCHAR2
,   p_pricing_attribute89           IN VARCHAR2
,   p_pricing_attribute90           IN VARCHAR2
,   p_pricing_attribute91           IN VARCHAR2
,   p_pricing_attribute92           IN VARCHAR2
,   p_pricing_attribute93           IN VARCHAR2
,   p_pricing_attribute94           IN VARCHAR2
,   p_pricing_attribute95           IN VARCHAR2
,   p_pricing_attribute96           IN VARCHAR2
,   p_pricing_attribute97           IN VARCHAR2
,   p_pricing_attribute98           IN VARCHAR2
,   p_pricing_attribute99           IN VARCHAR2
,   p_pricing_attribute100          IN VARCHAR2
,   p_pricing_context               IN VARCHAR2
,   p_flex_title				 IN VARCHAR2
, x_flex_title OUT NOCOPY VARCHAR2
, x_order_price_attrib_id OUT NOCOPY NUMBER
, x_header_id OUT NOCOPY NUMBER
, x_line_id OUT NOCOPY NUMBER
, x_context OUT NOCOPY VARCHAR2
, x_attribute1 OUT NOCOPY VARCHAR2
, x_attribute2 OUT NOCOPY VARCHAR2
, x_attribute3 OUT NOCOPY VARCHAR2
, x_attribute4 OUT NOCOPY VARCHAR2
, x_attribute5 OUT NOCOPY VARCHAR2
, x_attribute6 OUT NOCOPY VARCHAR2
, x_attribute7 OUT NOCOPY VARCHAR2
, x_attribute8 OUT NOCOPY VARCHAR2
, x_attribute9 OUT NOCOPY VARCHAR2
, x_attribute10 OUT NOCOPY VARCHAR2
, x_attribute11 OUT NOCOPY VARCHAR2
, x_attribute12 OUT NOCOPY VARCHAR2
, x_attribute13 OUT NOCOPY VARCHAR2
, x_attribute14 OUT NOCOPY VARCHAR2
, x_attribute15 OUT NOCOPY VARCHAR2
, x_pricing_attribute1 OUT NOCOPY VARCHAR2
, x_pricing_attribute10 OUT NOCOPY VARCHAR2
, x_pricing_attribute11 OUT NOCOPY VARCHAR2
, x_pricing_attribute12 OUT NOCOPY VARCHAR2
, x_pricing_attribute13 OUT NOCOPY VARCHAR2
, x_pricing_attribute14 OUT NOCOPY VARCHAR2
, x_pricing_attribute15 OUT NOCOPY VARCHAR2
, x_pricing_attribute2 OUT NOCOPY VARCHAR2
, x_pricing_attribute3 OUT NOCOPY VARCHAR2
, x_pricing_attribute4 OUT NOCOPY VARCHAR2
, x_pricing_attribute5 OUT NOCOPY VARCHAR2
, x_pricing_attribute6 OUT NOCOPY VARCHAR2
, x_pricing_attribute7 OUT NOCOPY VARCHAR2
, x_pricing_attribute8 OUT NOCOPY VARCHAR2
, x_pricing_attribute9 OUT NOCOPY VARCHAR2
, x_pricing_attribute16 OUT NOCOPY VARCHAR2
, x_pricing_attribute17 OUT NOCOPY VARCHAR2
, x_pricing_attribute18 OUT NOCOPY VARCHAR2
, x_pricing_attribute19 OUT NOCOPY VARCHAR2
, x_pricing_attribute20 OUT NOCOPY VARCHAR2
, x_pricing_attribute21 OUT NOCOPY VARCHAR2
, x_pricing_attribute22 OUT NOCOPY VARCHAR2
, x_pricing_attribute23 OUT NOCOPY VARCHAR2
, x_pricing_attribute24 OUT NOCOPY VARCHAR2
, x_pricing_attribute25 OUT NOCOPY VARCHAR2
, x_pricing_attribute26 OUT NOCOPY VARCHAR2
, x_pricing_attribute27 OUT NOCOPY VARCHAR2
, x_pricing_attribute28 OUT NOCOPY VARCHAR2
, x_pricing_attribute29 OUT NOCOPY VARCHAR2
, x_pricing_attribute30 OUT NOCOPY VARCHAR2
, x_pricing_attribute31 OUT NOCOPY VARCHAR2
, x_pricing_attribute32 OUT NOCOPY VARCHAR2
, x_pricing_attribute33 OUT NOCOPY VARCHAR2
, x_pricing_attribute34 OUT NOCOPY VARCHAR2
, x_pricing_attribute35 OUT NOCOPY VARCHAR2
, x_pricing_attribute36 OUT NOCOPY VARCHAR2
, x_pricing_attribute37 OUT NOCOPY VARCHAR2
, x_pricing_attribute38 OUT NOCOPY VARCHAR2
, x_pricing_attribute39 OUT NOCOPY VARCHAR2
, x_pricing_attribute40 OUT NOCOPY VARCHAR2
, x_pricing_attribute41 OUT NOCOPY VARCHAR2
, x_pricing_attribute42 OUT NOCOPY VARCHAR2
, x_pricing_attribute43 OUT NOCOPY VARCHAR2
, x_pricing_attribute44 OUT NOCOPY VARCHAR2
, x_pricing_attribute45 OUT NOCOPY VARCHAR2
, x_pricing_attribute46 OUT NOCOPY VARCHAR2
, x_pricing_attribute47 OUT NOCOPY VARCHAR2
, x_pricing_attribute48 OUT NOCOPY VARCHAR2
, x_pricing_attribute49 OUT NOCOPY VARCHAR2
, x_pricing_attribute50 OUT NOCOPY VARCHAR2
, x_pricing_attribute51 OUT NOCOPY VARCHAR2
, x_pricing_attribute52 OUT NOCOPY VARCHAR2
, x_pricing_attribute53 OUT NOCOPY VARCHAR2
, x_pricing_attribute54 OUT NOCOPY VARCHAR2
, x_pricing_attribute55 OUT NOCOPY VARCHAR2
, x_pricing_attribute56 OUT NOCOPY VARCHAR2
, x_pricing_attribute57 OUT NOCOPY VARCHAR2
, x_pricing_attribute58 OUT NOCOPY VARCHAR2
, x_pricing_attribute59 OUT NOCOPY VARCHAR2
, x_pricing_attribute60 OUT NOCOPY VARCHAR2
, x_pricing_attribute61 OUT NOCOPY VARCHAR2
, x_pricing_attribute62 OUT NOCOPY VARCHAR2
, x_pricing_attribute63 OUT NOCOPY VARCHAR2
, x_pricing_attribute64 OUT NOCOPY VARCHAR2
, x_pricing_attribute65 OUT NOCOPY VARCHAR2
, x_pricing_attribute66 OUT NOCOPY VARCHAR2
, x_pricing_attribute67 OUT NOCOPY VARCHAR2
, x_pricing_attribute68 OUT NOCOPY VARCHAR2
, x_pricing_attribute69 OUT NOCOPY VARCHAR2
, x_pricing_attribute70 OUT NOCOPY VARCHAR2
, x_pricing_attribute71 OUT NOCOPY VARCHAR2
, x_pricing_attribute72 OUT NOCOPY VARCHAR2
, x_pricing_attribute73 OUT NOCOPY VARCHAR2
, x_pricing_attribute74 OUT NOCOPY VARCHAR2
, x_pricing_attribute75 OUT NOCOPY VARCHAR2
, x_pricing_attribute76 OUT NOCOPY VARCHAR2
, x_pricing_attribute77 OUT NOCOPY VARCHAR2
, x_pricing_attribute78 OUT NOCOPY VARCHAR2
, x_pricing_attribute79 OUT NOCOPY VARCHAR2
, x_pricing_attribute80 OUT NOCOPY VARCHAR2
, x_pricing_attribute81 OUT NOCOPY VARCHAR2
, x_pricing_attribute82 OUT NOCOPY VARCHAR2
, x_pricing_attribute83 OUT NOCOPY VARCHAR2
, x_pricing_attribute84 OUT NOCOPY VARCHAR2
, x_pricing_attribute85 OUT NOCOPY VARCHAR2
, x_pricing_attribute86 OUT NOCOPY VARCHAR2
, x_pricing_attribute87 OUT NOCOPY VARCHAR2
, x_pricing_attribute88 OUT NOCOPY VARCHAR2
, x_pricing_attribute89 OUT NOCOPY VARCHAR2
, x_pricing_attribute90 OUT NOCOPY VARCHAR2
, x_pricing_attribute91 OUT NOCOPY VARCHAR2
, x_pricing_attribute92 OUT NOCOPY VARCHAR2
, x_pricing_attribute93 OUT NOCOPY VARCHAR2
, x_pricing_attribute94 OUT NOCOPY VARCHAR2
, x_pricing_attribute95 OUT NOCOPY VARCHAR2
, x_pricing_attribute96 OUT NOCOPY VARCHAR2
, x_pricing_attribute97 OUT NOCOPY VARCHAR2
, x_pricing_attribute98 OUT NOCOPY VARCHAR2
, x_pricing_attribute99 OUT NOCOPY VARCHAR2
, x_pricing_attribute100 OUT NOCOPY VARCHAR2
, x_pricing_context OUT NOCOPY VARCHAR2
, x_override_flag OUT NOCOPY VARCHAR2
,   p_called_from_pattr             IN  VARCHAR2 DEFAULT 'N'

);

PROCEDURE Change_Attributes
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,    p_order_price_attrib_id		 IN NUMBER
,    p_attr_id					 IN NUMBER
,	p_context					 IN VARCHAR2
,    p_attr_value				 IN VARCHAR2
,	p_attribute1				 IN VARCHAR2
,	p_attribute2				 IN VARCHAR2
,	p_attribute3				 IN VARCHAR2
,	p_attribute4				 IN VARCHAR2
,	p_attribute5				 IN VARCHAR2
,	p_attribute6				 IN VARCHAR2
,	p_attribute7				 IN VARCHAR2
,	p_attribute8				 IN VARCHAR2
,	p_attribute9				 IN VARCHAR2
,	p_attribute10				 IN VARCHAR2
,	p_attribute11				 IN VARCHAR2
,	p_attribute12				 IN VARCHAR2
,	p_attribute13				 IN VARCHAR2
,	p_attribute14				 IN VARCHAR2
,	p_attribute15				 IN VARCHAR2
,   p_pricing_attribute1            IN VARCHAR2
,   p_pricing_attribute10           IN VARCHAR2
,   p_pricing_attribute11           IN VARCHAR2
,   p_pricing_attribute12           IN VARCHAR2
,   p_pricing_attribute13           IN VARCHAR2
,   p_pricing_attribute14           IN VARCHAR2
,   p_pricing_attribute15           IN VARCHAR2
,   p_pricing_attribute2            IN VARCHAR2
,   p_pricing_attribute3            IN VARCHAR2
,   p_pricing_attribute4            IN VARCHAR2
,   p_pricing_attribute5            IN VARCHAR2
,   p_pricing_attribute6            IN VARCHAR2
,   p_pricing_attribute7            IN VARCHAR2
,   p_pricing_attribute8            IN VARCHAR2
,   p_pricing_attribute9            IN VARCHAR2
,   p_pricing_attribute16           IN VARCHAR2
,   p_pricing_attribute17           IN VARCHAR2
,   p_pricing_attribute18           IN VARCHAR2
,   p_pricing_attribute19           IN VARCHAR2
,   p_pricing_attribute20           IN VARCHAR2
,   p_pricing_attribute21           IN VARCHAR2
,   p_pricing_attribute22           IN VARCHAR2
,   p_pricing_attribute23           IN VARCHAR2
,   p_pricing_attribute24           IN VARCHAR2
,   p_pricing_attribute25           IN VARCHAR2
,   p_pricing_attribute26           IN VARCHAR2
,   p_pricing_attribute27           IN VARCHAR2
,   p_pricing_attribute28           IN VARCHAR2
,   p_pricing_attribute29           IN VARCHAR2
,   p_pricing_attribute30           IN VARCHAR2
,   p_pricing_context               IN VARCHAR2
,   p_flex_title				 IN VARCHAR2
, x_flex_title OUT NOCOPY VARCHAR2
, x_order_price_attrib_id OUT NOCOPY NUMBER
, x_header_id OUT NOCOPY NUMBER
, x_line_id OUT NOCOPY NUMBER
, x_context OUT NOCOPY VARCHAR2
, x_attribute1 OUT NOCOPY VARCHAR2
, x_attribute2 OUT NOCOPY VARCHAR2
, x_attribute3 OUT NOCOPY VARCHAR2
, x_attribute4 OUT NOCOPY VARCHAR2
, x_attribute5 OUT NOCOPY VARCHAR2
, x_attribute6 OUT NOCOPY VARCHAR2
, x_attribute7 OUT NOCOPY VARCHAR2
, x_attribute8 OUT NOCOPY VARCHAR2
, x_attribute9 OUT NOCOPY VARCHAR2
, x_attribute10 OUT NOCOPY VARCHAR2
, x_attribute11 OUT NOCOPY VARCHAR2
, x_attribute12 OUT NOCOPY VARCHAR2
, x_attribute13 OUT NOCOPY VARCHAR2
, x_attribute14 OUT NOCOPY VARCHAR2
, x_attribute15 OUT NOCOPY VARCHAR2
, x_pricing_attribute1 OUT NOCOPY VARCHAR2
, x_pricing_attribute10 OUT NOCOPY VARCHAR2
, x_pricing_attribute11 OUT NOCOPY VARCHAR2
, x_pricing_attribute12 OUT NOCOPY VARCHAR2
, x_pricing_attribute13 OUT NOCOPY VARCHAR2
, x_pricing_attribute14 OUT NOCOPY VARCHAR2
, x_pricing_attribute15 OUT NOCOPY VARCHAR2
, x_pricing_attribute2 OUT NOCOPY VARCHAR2
, x_pricing_attribute3 OUT NOCOPY VARCHAR2
, x_pricing_attribute4 OUT NOCOPY VARCHAR2
, x_pricing_attribute5 OUT NOCOPY VARCHAR2
, x_pricing_attribute6 OUT NOCOPY VARCHAR2
, x_pricing_attribute7 OUT NOCOPY VARCHAR2
, x_pricing_attribute8 OUT NOCOPY VARCHAR2
, x_pricing_attribute9 OUT NOCOPY VARCHAR2
, x_pricing_attribute16 OUT NOCOPY VARCHAR2
, x_pricing_attribute17 OUT NOCOPY VARCHAR2
, x_pricing_attribute18 OUT NOCOPY VARCHAR2
, x_pricing_attribute19 OUT NOCOPY VARCHAR2
, x_pricing_attribute20 OUT NOCOPY VARCHAR2
, x_pricing_attribute21 OUT NOCOPY VARCHAR2
, x_pricing_attribute22 OUT NOCOPY VARCHAR2
, x_pricing_attribute23 OUT NOCOPY VARCHAR2
, x_pricing_attribute24 OUT NOCOPY VARCHAR2
, x_pricing_attribute25 OUT NOCOPY VARCHAR2
, x_pricing_attribute26 OUT NOCOPY VARCHAR2
, x_pricing_attribute27 OUT NOCOPY VARCHAR2
, x_pricing_attribute28 OUT NOCOPY VARCHAR2
, x_pricing_attribute29 OUT NOCOPY VARCHAR2
, x_pricing_attribute30 OUT NOCOPY VARCHAR2
, x_pricing_context OUT NOCOPY VARCHAR2
, x_override_flag OUT NOCOPY VARCHAR2
,   p_called_from_pattr             IN  VARCHAR2 DEFAULT 'N'

);


PROCEDURE Validate_And_Write
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_order_price_attrib_id         IN  NUMBER
, x_creation_date OUT NOCOPY DATE
, x_created_by OUT NOCOPY NUMBER
, x_last_update_date OUT NOCOPY DATE
, x_last_updated_by OUT NOCOPY NUMBER
, x_last_update_login OUT NOCOPY NUMBER
, x_program_id OUT NOCOPY NUMBER
, x_program_application_id OUT NOCOPY NUMBER
, x_program_update_date OUT NOCOPY DATE
, x_request_id OUT NOCOPY NUMBER
, x_lock_control OUT NOCOPY NUMBER
,   p_called_from_pattr             IN  VARCHAR2 DEFAULT 'N'
);


PROCEDURE Delete_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_order_price_attrib_id         IN  NUMBER
);

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_order_price_attrib_id         IN  NUMBER
,   p_lock_control                  IN  NUMBER
);

procedure process_price(x_return_status OUT NOCOPY Varchar2);

END OE_OE_Form_Line_PAttr;

 

/
