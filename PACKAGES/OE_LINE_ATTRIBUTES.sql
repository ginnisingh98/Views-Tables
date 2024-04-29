--------------------------------------------------------
--  DDL for Package OE_LINE_ATTRIBUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_LINE_ATTRIBUTES" AUTHID CURRENT_USER AS
/* $Header: OEXLATTS.pls 115.1 99/07/16 08:13:08 porting shi $ */

/*
** set_so_line_attributes is called from OrderImport to manipulate so_line_attributes
** given the records in so_line_attributes_interface
*/

PROCEDURE set_so_line_attributes
  (in_line_id		IN NUMBER,
   in_op_code	        IN VARCHAR2,
   in_ord_source	IN VARCHAR2,
   in_orig_sys_ref	IN VARCHAR2,
   in_orig_sys_l_ref    IN VARCHAR2,
   in_req_id	        IN NUMBER,
   out_result	        OUT NUMBER   );

/*
** set_industry_attributes is called from oeoord.lpc
** to insert(delete) a complementing null record into so_line_attributes
** whenever a line is inserted(deleted) into so_lines.
** Also called from Order User Exit to update records when in GUI mode,
** or to insert/delete records when in Character mode.
*/

PROCEDURE set_industry_attributes
  (in_op_code                    IN VARCHAR2,
   in_line_id                    IN NUMBER,
   in_industry_context           IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute1        IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute2        IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute3        IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute4        IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute5        IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute6        IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute7        IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute8        IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute9        IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute10       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute11       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute12       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute13       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute14       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute15       IN VARCHAR2 DEFAULT NULL,
   in_global_attribute_category  IN VARCHAR2 DEFAULT NULL,
   in_global_attribute1          IN VARCHAR2 DEFAULT NULL,
   in_global_attribute2          IN VARCHAR2 DEFAULT NULL,
   in_global_attribute3          IN VARCHAR2 DEFAULT NULL,
   in_global_attribute4          IN VARCHAR2 DEFAULT NULL,
   in_global_attribute5          IN VARCHAR2 DEFAULT NULL,
   in_global_attribute6          IN VARCHAR2 DEFAULT NULL,
   in_global_attribute7          IN VARCHAR2 DEFAULT NULL,
   in_global_attribute8          IN VARCHAR2 DEFAULT NULL,
   in_global_attribute9          IN VARCHAR2 DEFAULT NULL,
   in_global_attribute10         IN VARCHAR2 DEFAULT NULL,
   in_global_attribute11         IN VARCHAR2 DEFAULT NULL,
   in_global_attribute12         IN VARCHAR2 DEFAULT NULL,
   in_global_attribute13         IN VARCHAR2 DEFAULT NULL,
   in_global_attribute14         IN VARCHAR2 DEFAULT NULL,
   in_global_attribute15         IN VARCHAR2 DEFAULT NULL,
   in_global_attribute16         IN VARCHAR2 DEFAULT NULL,
   in_global_attribute17         IN VARCHAR2 DEFAULT NULL,
   in_global_attribute18         IN VARCHAR2 DEFAULT NULL,
   in_global_attribute19         IN VARCHAR2 DEFAULT NULL,
   in_global_attribute20         IN VARCHAR2 DEFAULT NULL
        );

/*
** get_industry_attributes is called from oexobj.lpc
** to get industry attributes from the database given a line_id.
** This is used to resolve locking issue.
*/

PROCEDURE get_industry_attributes
  (in_op_code                   IN VARCHAR2,
   in_line_id                   IN NUMBER,
   out_industry_context         OUT  VARCHAR2 ,
   out_industry_attribute1      OUT  VARCHAR2 ,
   out_industry_attribute2      OUT  VARCHAR2 ,
   out_industry_attribute3      OUT  VARCHAR2 ,
   out_industry_attribute4      OUT  VARCHAR2 ,
   out_industry_attribute5      OUT  VARCHAR2 ,
   out_industry_attribute6      OUT  VARCHAR2 ,
   out_industry_attribute7      OUT  VARCHAR2 ,
   out_industry_attribute8      OUT  VARCHAR2 ,
   out_industry_attribute9      OUT  VARCHAR2 ,
   out_industry_attribute10     OUT  VARCHAR2 ,
   out_industry_attribute11     OUT  VARCHAR2 ,
   out_industry_attribute12     OUT  VARCHAR2 ,
   out_industry_attribute13     OUT  VARCHAR2 ,
   out_industry_attribute14     OUT  VARCHAR2 ,
   out_industry_attribute15     OUT  VARCHAR2,
   out_global_attribute_category      OUT  VARCHAR2 ,
   out_global_attribute1              OUT  VARCHAR2 ,
   out_global_attribute2              OUT  VARCHAR2 ,
   out_global_attribute3              OUT  VARCHAR2 ,
   out_global_attribute4              OUT  VARCHAR2 ,
   out_global_attribute5              OUT  VARCHAR2 ,
   out_global_attribute6              OUT  VARCHAR2 ,
   out_global_attribute7              OUT  VARCHAR2 ,
   out_global_attribute8              OUT  VARCHAR2 ,
   out_global_attribute9              OUT  VARCHAR2 ,
   out_global_attribute10             OUT  VARCHAR2 ,
   out_global_attribute11             OUT  VARCHAR2 ,
   out_global_attribute12             OUT  VARCHAR2 ,
   out_global_attribute13             OUT  VARCHAR2 ,
   out_global_attribute14             OUT  VARCHAR2 ,
   out_global_attribute15             OUT  VARCHAR2 ,
   out_global_attribute16             OUT  VARCHAR2 ,
   out_global_attribute17             OUT  VARCHAR2 ,
   out_global_attribute18             OUT  VARCHAR2 ,
   out_global_attribute19             OUT  VARCHAR2 ,
   out_global_attribute20     OUT  VARCHAR2
   );
END oe_line_attributes;

 

/
