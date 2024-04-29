--------------------------------------------------------
--  DDL for Package PAY_PAYROLL_XML_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYROLL_XML_EXTRACT_PKG" AUTHID CURRENT_USER as
/* $Header: pyxmlxtr.pkh 120.6.12010000.2 2008/08/22 10:30:51 ckesanap ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2004, Oracle India Pvt. Ltd., Hyderabad         *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_payroll_xml_extract_pkg

    Description : This package handles generation of XML from data archived
                  in pay_action_information. Calling applications can invoke
                  one of the overloaded versions of GENERATE procedure with
                  appropriate parameters to obtain the XML. This package has
                  other public procedures which GENERATE uses for processing.
                  They might not be of much use if invoked directly by calling
                  applications.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    23-NOV-2004 sdahiya    115.0            Created.
    22-DEC-2004 sdahiya    115.1            Modified csr_get_archived_info to
                                            retrieve records archived at payroll
                                            action level too.
    20-FEB-2005 sdahiya    115.2            Modified parameters of GENERATE
                                            procedure.
    11-JUL-2005 sdahiya    115.3            Added overloaded versions of
                                            GENERATE procedure so that it can be
                                            driven off action_information_id
                                            too.
    15-JUL-2005 sdahiya    115.4            Modified signature of GENERATE
                                            overloaded procedure to handle
                                            custom XML tags.
    01-AUG-2005 sdahiya    115.5            Added support for localization
                                            package and removed
                                            DocumentProcessor XML tags.
    18-AUG-2005 sdahiya    115.6            Added LOAD_XML_DATA procedure and
                                            global variable g_xml_table.
    20-NOV-2005 vmehta     115.7            Added overloaded version of LOAD_XML
                                            which accepts flexfield name.
    21-NOV-2005 sdahiya    115.8   4773967  Modified procedure signatures to
                                            return XML as BLOB instead of CLOB.
    21-Aug-2008 jalin      115.9   6522667  Fixed performance issue, changed to
                                            use UNION_ALL function in csr_get_
                                            archived_info cursor
  *****************************************************************************/

TYPE int_tab_type IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
TYPE char_tab_type IS TABLE OF pay_action_information.action_information1%type
                                                        INDEX BY BINARY_INTEGER;
TYPE param_rec IS RECORD (
    parameter_name  varchar2(50),
    parameter_value varchar2(500)
);
TYPE param_tab_type IS TABLE OF param_rec INDEX BY BINARY_INTEGER;

  /****************************************************************************
    Name        : LOAD_XML
    Description : This procedure loads the global XML cache.
    Parameters  : P_NODE_TYPE       This parameter can take one of these values: -
                                        1. CS - This signifies that string contained in
                                                P_NODE parameter is start of container
                                                node. P_DATA parameter is ignored in this
                                                mode.
                                        2. CE - This signifies that string contained in
                                                P_NODE parameter is end of container
                                                node. P_DATA parameter is ignored in this
                                                mode.
                                        3. D  - This signifies that string contained in
                                                P_NODE parameter is data node and P_DATA
                                                carries actual data to be contained by
                                                tag specified by P_NODE parameter.

                  P_CONTEXT_CODE    Context code of descriptive flexfield.

                  P_NODE            Name of XML tag, or, application column name of flex segment.

                  P_DATA            Data to be contained by tag specified by P_NODE parameter.
                                    P_DATA is not used unless P_NODE_TYPE = D.
  *****************************************************************************/
PROCEDURE LOAD_XML (
    P_NODE_TYPE         varchar2,
    P_FLEXFIELD_NAME    varchar2,
    P_CONTEXT_CODE      varchar2,
    P_NODE              varchar2,
    P_DATA              varchar2
);


/****************************************************************************
    Name        : LOAD_XML
    Description : This procedure obtains segment titles from the Action
                  Information DF. This is temporary, and is created only to
                  provide backward compatibility for payslip code. Once the
                  payslip processes are changed to pass the flexfield name,
                  this procedure can be removed.
 *****************************************************************************/
PROCEDURE LOAD_XML (
    P_NODE_TYPE      varchar2,
    P_CONTEXT_CODE   varchar2,
    P_NODE           varchar2,
    P_DATA           varchar2
);

  /****************************************************************************
    Name        : LOAD_XML
    Description : This procedure obtains segment title from the bank key
                  flexfield to be used as XML tag.
  *****************************************************************************/
PROCEDURE LOAD_XML (
    P_NODE_TYPE         varchar2,
    P_NODE              varchar2,
    P_DATA              varchar2
);


  /****************************************************************************
    Name        : LOAD_XML
    Description : This procedure accepts a well-formed XML and loads it into
                  global XML cache. Note that this procedure does not perform
                  any syntactical validations over passed XML data.
                  LOAD_XML_DATA should be used if such validations are required
                  to be performed implicitly.
  *****************************************************************************/
PROCEDURE LOAD_XML (
    P_XML               pay_action_information.action_information1%type
);


  /****************************************************************************
    Name        : LOAD_XML_DATA
    Description : This procedure accepts meta-data along with actual XML data
                  and loads the global XML cache. This is a public procedure
                  which performs basic validations to check well-formedness of
                  XML data before loading the cache. Please see parameter
                  description of public version of LOAD_XML to find what each
                  parameter signifies.
  *****************************************************************************/
PROCEDURE LOAD_XML_DATA (
    P_NODE_TYPE         varchar2,
    P_NODE              varchar2,
    P_DATA              varchar2
);

  /****************************************************************************
    Name        : GENERATE
    Description : This procedure interprets archived information, converts it to
                  XML and prints it out to a BLOB. This is a public procedure
                  and is based on action_context_IDs passed by the calling
                  process. All archived records belonging to passed
                  action_context_id will be converted to XML. Currently, online
                  payslip and MX Pay Advice invoke this overloaded version.
  *****************************************************************************/
PROCEDURE GENERATE (
    P_ACTION_CONTEXT_ID         number,
    P_CUSTOM_XML_PROCEDURE      varchar2,
    P_GENERATE_HEADER_FLAG      varchar2, -- {Y/N}
    P_ROOT_TAG                  varchar2,
    P_DOCUMENT_TYPE             varchar2,
    P_XML                       OUT NOCOPY BLOB
);


  /****************************************************************************
    Name        : GENERATE
    Description : This procedure interprets archived information, converts it to
                  XML and prints it out to a BLOB. This is a public procedure
                  and is driven off action_information_IDs set by the calling
                  process.

                  It also accepts a custom XML tag parameter, which if passed a
                  non-null value, will be used as parent enclosing tag of each
                  action_information_id irrespective of the actual action
                  information category.

                  Currently, MX SUA process invokes this overloaded version.
  *****************************************************************************/

PROCEDURE GENERATE (
    P_ACTION_INF_ID_TAB         int_tab_type,
    P_CUSTOM_ACTION_INFO_CAT    varchar2,
    P_DOCUMENT_TYPE             varchar2,
    P_XML                       OUT NOCOPY BLOB
);

/*---- Global declarations ---*/
g_leg_code      fnd_territories.territory_code%type;
g_xml_table     char_tab_type;
g_custom_xml    char_tab_type;
g_custom_params param_tab_type;

CURSOR csr_get_archived_info (p_action_context_id   number,
                              p_category            varchar2,
                              p_category_filter     varchar2,
                              p_action_information_id number) IS
    SELECT effective_date,
           action_information1,
           action_information2,
           action_information3,
           action_information4,
           action_information5,
           action_information6,
           action_information7,
           action_information8,
           action_information9,
           action_information10,
           action_information11,
           action_information12,
           action_information13,
           action_information14,
           action_information15,
           action_information16,
           action_information17,
           action_information18,
           action_information19,
           action_information20,
           action_information21,
           action_information22,
           action_information23,
           action_information24,
           action_information25,
           action_information26,
           action_information27,
           action_information28,
           action_information29,
           action_information30
      FROM pay_action_information
     WHERE (action_information_id = p_action_information_id AND p_action_information_id IS NOT NULL)
       AND action_information_category = p_category
    UNION ALL /* Bug 6522667, added UNION ALL */
    SELECT effective_date,
           action_information1,
           action_information2,
           action_information3,
           action_information4,
           action_information5,
           action_information6,
           action_information7,
           action_information8,
           action_information9,
           action_information10,
           action_information11,
           action_information12,
           action_information13,
           action_information14,
           action_information15,
           action_information16,
           action_information17,
           action_information18,
           action_information19,
           action_information20,
           action_information21,
           action_information22,
           action_information23,
           action_information24,
           action_information25,
           action_information26,
           action_information27,
           action_information28,
           action_information29,
           action_information30
      FROM pay_action_information
     WHERE ((action_context_id = p_action_context_id AND action_context_type = 'AAP') OR
            (action_context_id = (SELECT payroll_action_id
                                    FROM pay_assignment_actions
                                   WHERE assignment_action_id = p_action_context_id)
             AND action_context_type = 'PA'
             AND ((action_information1 = p_category_filter AND
                  p_category IN ('ADDRESS DETAILS', pay_payroll_xml_extract_pkg.g_leg_code || ' EMPLOYER DETAILS')) OR
                 (p_category NOT IN ('ADDRESS DETAILS', pay_payroll_xml_extract_pkg.g_leg_code || ' EMPLOYER DETAILS')))))
       AND action_information_category = p_category;

    CURSOR csr_payroll_details (p_time_period_id number) IS
        SELECT ppf.payroll_name,
               ptp.period_type,
               substr(fnd_date.date_to_canonical(ptp.start_date),1,10) start_date,
               substr(fnd_date.date_to_canonical(ptp.end_date),1,10) end_date
          FROM pay_payrolls_f ppf,
               per_time_periods ptp
         WHERE ppf.payroll_id = ptp.payroll_id
           AND ptp.time_period_id = p_time_period_id;

END PAY_PAYROLL_XML_EXTRACT_PKG;


/
