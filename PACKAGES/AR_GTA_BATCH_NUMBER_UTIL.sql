--------------------------------------------------------
--  DDL for Package AR_GTA_BATCH_NUMBER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_GTA_BATCH_NUMBER_UTIL" AUTHID CURRENT_USER AS
  ----$Header: ARGGBNUS.pls 120.0.12010000.3 2010/01/19 07:17:52 choli noship $
  --+===========================================================================+
  --|                    Copyright (c) 2005 Oracle Corporation                  |
  --|                      Redwood Shores, California, USA                      |
  --|                            All rights reserved.                           |
  --+===========================================================================+
  --|                                                                           |
  --|  FILENAME :                                                               |
  --|      ARGBNUS.pls                                                         |
  --|                                                                           |
  --|  DESCRIPTION:                                                             |
  --|      This package is a collection of  the util procedure                  |
  --|      or function for auto batch numbering.                                |
  --|                                                                           |
  --|                                                                           |
  --|  HISTORY:                                                                 |
  --|       20-APR-2005: Qiang Li  Created                                      |
  --|                                                                           |
  --+===========================================================================+

  --Declare global variable for package name
  g_module_prefix VARCHAR2(40) := 'ar.plsql.AR_GTA_BATCH_NUMBER_UTIL';

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    create_seq                       Public
  --
  --  DESCRIPTION:
  --
  --      This procedure create a new sequence for a given operating unit
  --
  --  PARAMETERS:
  --      In:  p_org_id         the operating unit id for the new sequence
  --           p_next_value     the start value of the sequence
  --     Out:  x_return_status  the return value to indicate the status
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --
  --===========================================================================

  PROCEDURE Create_Seq
  ( p_org_id        IN NUMBER
  , p_next_value    IN NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  );

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    set_nextval                       Public
  --
  --  DESCRIPTION:
  --
  --      This procedure set the sequence's next value for a given operating unit
  --
  --  PARAMETERS:
  --      In:  p_org_id         the operating unit id for the new sequence
  --           p_next_value     the start value of the sequence
  --     Out:  x_return_status  the return value to indicate the status
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --
  --===========================================================================
  PROCEDURE Set_Nextval
  ( p_org_id        IN NUMBER
  , p_next_value    IN NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  );

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    next_value                   Public
  --
  --  DESCRIPTION:
  --
  --      This function get the sequence's current value and then increase it
  --
  --  PARAMETERS:
  --      In:   p_org_id        Identifier of operating unit
  --
  --
  --  Return:   NUMBER
  --
  --  DESIGN REFERENCES:
  --      GTA-System-Options-Form-TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --
  --===========================================================================
  FUNCTION Next_Value
  (p_org_id IN NUMBER
  )
  RETURN NUMBER;
  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    drop_seq                       Public
  --
  --  DESCRIPTION:
  --
  --      This procedure drop the sequence of a given operating unit
  --
  --  PARAMETERS:
  --      In:  p_org_id         the operating unit id for the new sequence
  --
  --     Out:  x_return_status  the return value to indicate the status
  --
  --  DESIGN REFERENCES:
  --        GTA-System-Options-Form-TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --
  --===========================================================================
  PROCEDURE Drop_Seq
  ( p_org_id        IN NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  );
  --==========================================================================
  --  FUNCTION NAME:
  --
  --    is_number                   Public
  --
  --  DESCRIPTION:
  --
  --      This function check the input value to see whether it is a number
  --
  --  PARAMETERS:
  --      In:   p_value        input value to check
  --
  --
  --  Return:   NUMBER
  --
  --  DESIGN REFERENCES:
  --      GTA-System-Options-Form-TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --
  --===========================================================================
  FUNCTION Is_Number
  (p_value IN VARCHAR2
  )
  RETURN NUMBER;
  --==========================================================================
  --  FUNCTION NAME:
  --
  --    verify_next_batch_number                   Public
  --
  --  DESCRIPTION:
  --
  --      This function verify the given next value for a operating unit to
  --      see whether the next value is bigger than the exist batch number
  --  PARAMETERS:
  --      In:  p_org_id         the operating unit id
  --           p_next_value     the next value to verify
  --  Return:   VARCHAR2
  --
  --  DESIGN REFERENCES:
  --      GTA-System-Options-Form-TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --
  --===========================================================================
  FUNCTION Verify_Next_Batch_Number
  ( p_org_id     IN NUMBER
  , p_next_value IN NUMBER
  )
  RETURN VARCHAR2;
  --==========================================================================
  --  FUNCTION NAME:
  --
  --    is_exist                   Public
  --
  --  DESCRIPTION:
  --
  --      This function is used to check whether the given org_id has a sequence
  --      in the database
  --  PARAMETERS:
  --      In:  p_org_id         the operating unit id
  --
  --  Return:   VARCHAR2
  --
  --  DESIGN REFERENCES:
  --      GTA-System-Options-Form-TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --
  --===========================================================================
  FUNCTION Is_Exist
  (p_org_id IN NUMBER
  )
  RETURN VARCHAR2;
  --==========================================================================
  --  FUNCTION NAME:
  --
  --    current_value                   Public
  --
  --  DESCRIPTION:
  --
  --      This function is used to get the current value of a sequence
  --  PARAMETERS:
  --      In:  p_org_id         the operating unit id
  --
  --  Return:   VARCHAR2
  --
  --  DESIGN REFERENCES:
  --      GTA-System-Options-Form-TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --
  --===========================================================================
  FUNCTION Current_Value
  (p_org_id IN NUMBER
  )
  RETURN NUMBER;
END AR_GTA_BATCH_NUMBER_UTIL;

/
