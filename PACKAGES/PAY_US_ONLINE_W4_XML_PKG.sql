--------------------------------------------------------
--  DDL for Package PAY_US_ONLINE_W4_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_ONLINE_W4_XML_PKG" 
/* $Header: pyw4xmlp.pkh 120.0.12010000.1 2008/07/28 00:01:22 appldev ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2005 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material AUTHID CURRENT_USER is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_online_w4_xml_pkg

    Description : This package contains the procedure generate_xml to
                  generate the XML extract for Online W4 PDF

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------
    31-MAY-2005 rsethupa   115.0            Created

    *****************************************************************

    ****************************************************************************
    Procedure Name: generate_xml
    Description: Returns the XML extract for Online W4 PDF
    ***************************************************************************/
AS
   PROCEDURE generate_xml (
      p_person_id             IN per_people_f.person_id%TYPE,
      p_transaction_step_id   IN hr_api_transaction_steps.transaction_step_id%TYPE,
      p_temp_dir              IN VARCHAR2,
      p_appl_short_name       IN VARCHAR2,
      p_template_code         IN VARCHAR2,
      p_default_language      IN VARCHAR2,
      p_default_territory     IN VARCHAR2,
      p_xml_string            OUT NOCOPY VARCHAR2
   );

   TYPE xml_data_rec IS RECORD (
      xml_tag    VARCHAR2 (100),
      xml_data   VARCHAR2 (300)
   );

   TYPE xml_data_table IS TABLE OF xml_data_rec
      INDEX BY BINARY_INTEGER;

   l_xml_data_table   xml_data_table;
END pay_us_online_w4_xml_pkg;

/
