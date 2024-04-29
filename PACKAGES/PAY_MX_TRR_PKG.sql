--------------------------------------------------------
--  DDL for Package PAY_MX_TRR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_TRR_PKG" AUTHID CURRENT_USER AS
/* $Header: pymxtrr.pkh 120.2.12010000.1 2008/07/27 23:10:28 appldev ship $ */
--
/*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, IN      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   01-DEC-2004  ssmukher    115.0           Created.
   18-APR-2005  kthirmiy    115.1           Increased tag_value to 80 chars
   06-FEB-2006  vmehta      115.2           Added parameters to
                                            fetch_active_assg_act.
   29-Mar-2006  vmehta      115.3           Removed function:
                                            fetch_active_assg_act, as it is
                                            used locally in pkb.
*/
--
  TYPE  xml_rec IS RECORD ( tag_name  VARCHAR2(50)
                           ,tag_value VARCHAR2(80)
                           ,tag_type  CHAR(1));

  TYPE xml_data IS TABLE OF  xml_rec
       INDEX BY BINARY_INTEGER;

  l_counter NUMBER;

  FUNCTION fetch_define_bal (p_bal_name    IN VARCHAR2
  		            ,p_data_suffix IN VARCHAR2)
  RETURN NUMBER;

  PROCEDURE populate_plsql_table
          ( p_start_date_earned   IN DATE,
            p_end_date_earned     IN DATE,
            p_legal_employer_id   IN NUMBER,
            p_state_code          IN VARCHAR2,
            p_gre_id              IN NUMBER,
            p_show_isr            IN VARCHAR2,
            p_show_soc_security   IN VARCHAR2,
            p_show_state          IN VARCHAR2,
            p_dimension           IN VARCHAR2,
            p_business_group_id   IN NUMBER,
            p_xml_data            IN OUT NOCOPY XML_DATA ) ;


  PROCEDURE trr_report_wrapper
	      (errbuf                OUT NOCOPY VARCHAR2,
               retcode               OUT NOCOPY NUMBER,
               p_business_group_id   IN NUMBER,
	       p_start_date_earned   IN VARCHAR2,
	       p_end_date_earned     IN VARCHAR2,
	       p_legal_employer_id   IN NUMBER,
	       p_state_code          IN VARCHAR2,
	       p_gre_id              IN NUMBER,
	       p_show_isr            IN VARCHAR2,
	       p_show_soc_security   IN VARCHAR2,
	       p_show_state          IN VARCHAR2,
	       p_dimension           IN VARCHAR2,
	       p_template            IN VARCHAR2,
	       p_template_locale     IN VARCHAR2,
               p_session_date        IN VARCHAR2);

  procedure populate_trr_Report
	      (errbuf                OUT NOCOPY VARCHAR2,
               retcode               OUT NOCOPY NUMBER,
               p_business_group_id   IN NUMBER,
               p_start_date_earned   IN VARCHAR2,
               p_end_date_earned     IN VARCHAR2,
               p_legal_employer_id   IN NUMBER,
               p_state_code          IN VARCHAR2,
               p_gre_id              IN NUMBER,
               p_show_isr            IN VARCHAR2,
               p_show_soc_security   IN VARCHAR2,
               p_show_state          IN VARCHAR2,
               p_dimension           IN VARCHAR2,
               p_session_date        IN VARCHAR2);


END PAY_MX_TRR_PKG;

/
