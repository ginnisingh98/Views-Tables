--------------------------------------------------------
--  DDL for Package GL_AFF_AWC_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AFF_AWC_API_PKG" AUTHID CURRENT_USER AS
/* $Header: gluafaws.pls 120.0 2005/10/03 19:47:32 spala noship $ */

   -- Public functions

  --
  -- Function
  --   gl_coa_awc_rule
  -- Purpose
  --  This is a rule function. This function will be executed
  --  When a accounting flexfield was submitted for compilation through form.
  --  The function will be called when the business event,
  --  "oracle.apps.fnd.flex.kff.structure.compiled" raised by KFF form.
  -- History
   --   28-Jul-05  Srini Pala    Created
  --
  -- Arguments
  --   p_subscription_guid   Business Event key
  --   p_eevnt               Business Event.
  --
  --
  --
  --
  -- Example
  --   gl_global.gl_coa_awc_rule(#####, '####');
  -- Notes
  --


   FUNCTION gl_coa_awc_rule(p_subscription_guid IN RAW,
                            p_event             IN OUT NOCOPY WF_EVENT_T)
                             RETURN VARCHAR2;

  --
  -- Procedure
  --   gl_bs_add_awc
  -- Purpose
  --  This function adds a new additional where clause to balancing segment.
  --
  --
  --
  -- History
   --   04-Jul-05  Srini Pala    Created
  --
  -- Arguments
  --   coa_id                      Chart of accounts id
  --   segment_type                Flexfield qualifier
  --
  --
  --
  --
  -- Example
  --   gl_global.gl_bs_add_awc(101, 'GL_BALANCING');
  -- Notes
  --

   PROCEDURE gl_bs_add_awc (coa_id  NUMBER,
                            segment_type IN VARCHAR2);


   FUNCTION  gl_valid_flex_values (p_valid_date   VARCHAR2,
                                   p_flex_value   VARCHAR2,
                                   p_id1          NUMBER DEFAULT NULL,
                                   p_char1        VARCHAR2 DEFAULT NULL,
                                   p_id2          NUMBER DEFAULT NULL,
                                   p_char2        VARCHAR2 DEFAULT NULL,
                                   p_id3          NUMBER DEFAULT NULL,
                                   p_char3        VARCHAR2 DEFAULT NULL)
              RETURN VARCHAR2;

  --
  -- Procedure
  --   gl_bs_delete_awc
  -- Purpose
  --  This function deletes an existing additional
  --  where clause on the balancing segment of a chart of accounts.
  --  This function will be rarely used, when a balancing
  --  segment qualifier chnages to a different segment in
  --  in a chart of account. This happens very very rare
  --
  -- History
   --   04-Jul-05  Srini Pala    Created
  --
  -- Arguments
  --   coa_id                      Chart of accounts id
  --   segment_type                Flexfield qualifier
  --
  --
  --
  --
  -- Example
  --   gl_global.gl_bs_delete_awc(101, 'GL_BALANCING');
  -- Notes
  --

   PROCEDURE gl_bs_delete_awc (coa_id  NUMBER,
                                 segment_type IN VARCHAR2);


 --
  -- Procedure
  --   gl_global_library;
  -- Purpose
  --  This procedure will be called from FNDSQF library to
  --  set the context ledger id and increment the profile
  --  option value on the server side.
  --   This is required when the Flexfield: Validate on server
  --   profile option is turned on.
  --
  -- History
   --   29-AUG-05  Srini Pala    Created
  --
  -- Arguments

  --   Context Type        Ledger, Legal Entity, Operarting Unit.
  --   Context Id          Ledger Id, Ledgal Entity Id, Operating Entity Id.
  --
  -- Example
  --   GL_AFF_AWC_API_PKG.gl_global_library('LG', '1');
  -- Notes
  --

END GL_AFF_AWC_API_PKG;

 

/
