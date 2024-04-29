--------------------------------------------------------
--  DDL for Package JTF_IH_BULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_BULK" AUTHID CURRENT_USER AS
/* $Header: JTFIHBKS.pls 120.2 2005/12/13 04:23:02 nchouras noship $*/

-- data type to relate a media_identifier with a media_id
TYPE media_id_trkr_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- PROCEDURE
--    BULK_PROCESSOR_CONC
--
-- PURPOSE
--    Process bulk IH requests from the JTF_IH_BULK_Q.
--    This procedure is meant for use as a concurrent job.
--
-- PARAMETERS
--    errbuf  OUT VARCHAR2  - standard parameters for a concurrent
--    retcode OUT VARCHAR2  - process procedure
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE BULK_PROCESSOR_CONC
(
  errbuf  OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- FUNCTION
--    PROCESS_BULK_RECORD
--
-- PURPOSE
--    To process a single bulk request record from the AQ.
--
-- Description - Processes the input bulk interaction record. The optional
--               parameter allows processing to start at some offset besides the
--               beginning in the list of interactions.
--
-- PARAMETERS
-- p_bulk_writer_code          IN VARCHAR2  bulk writer code
-- p_bulk_batch_type           IN VARCHAR2  batch type
-- p_bulk_batch_id             IN NUMBER    batch id
-- p_bulk_interaction_request  IN CLOB      interaction request itself, xml doc
-- p_int_offset                IN  NUMBER   optional offset value to not process all
--
-- Returns
--    FND_API.G_RET_STS_SUCCESS if the record processed without any errors.
--    FND_API.G_RET_STS_ERROR   if any errors occur
--
-- NOTES
--
---------------------------------------------------------------------
FUNCTION PROCESS_BULK_RECORD
(
  p_bulk_writer_code          IN VARCHAR2,
  p_bulk_batch_type           IN VARCHAR2,
  p_bulk_batch_id             IN NUMBER,
  p_bulk_interaction_request  IN CLOB,
  p_int_offset                IN NUMBER DEFAULT 0
) RETURN VARCHAR2;

--
-- Utility function to handle media nodes for an interaction.
--
-- Parameters
--
--  med_nl                - IN  - dbms_xmldom.DomNodeList of media nodes
--  p_bulk_interaction_id - IN  - self explanatory
--  p_bulk_writer_code    - IN  - self explanatory
--  p_bulk_batch_type     - IN  - self explanatory
--  p_bulk_batch_id       - IN  - self explanatory
--  p_user_id             - IN  - user id of the user submitting the request
--  x_med_id_tbl          - OUT - this carries the media_identifier to media_id relation
--  x_ret_status          - OUT - self explanatory
--  x_ret_msg             - OUT - self explanatory
--
PROCEDURE PROCESS_MEDIA_ITEMS
(
  med_nl                IN            dbms_xmldom.DomNodeList,
  p_bulk_interaction_id IN            NUMBER,
  p_bulk_writer_code    IN            VARCHAR2,
  p_bulk_batch_type     IN            VARCHAR2,
  p_bulk_batch_id       IN            NUMBER,
  p_user_id             IN            NUMBER,
  x_med_id_tbl          IN OUT NOCOPY media_id_trkr_type,
  x_ret_status          IN OUT NOCOPY VARCHAR2,
  x_ret_msg             IN OUT NOCOPY VARCHAR2
);

--
-- Utility function to handle media nodes for an interaction.
--
-- Parameters
--
--  act_nl                - IN  - dbms_xmldom.DomNodeList of act nodes
--  p_bulk_interaction_id - IN  - self explanatory
--  p_bulk_writer_code    - IN  - self explanatory
--  p_bulk_batch_type     - IN  - self explanatory
--  p_bulk_batch_id       - IN  - self explanatory
--  med_id_tbl            - IN  - this carries the media_identifier to media_id relation
--  x_act_tbl             - OUT - parsed activity records collection
--  x_ret_status          - OUT - self explanatory
--  x_ret_msg             - OUT - self explanatory
--
PROCEDURE GATHER_ACT_TBL
(
  act_nl                IN            dbms_xmldom.DomNodeList,
  p_bulk_interaction_id IN            NUMBER,
  p_bulk_writer_code    IN            VARCHAR2,
  p_bulk_batch_type     IN            VARCHAR2,
  p_bulk_batch_id       IN            NUMBER,
  med_id_tbl            IN            media_id_trkr_type,
  x_act_tbl             IN OUT NOCOPY JTF_IH_PUB.ACTIVITY_TBL_TYPE,
  x_ret_status          IN OUT NOCOPY VARCHAR2,
  x_ret_msg             IN OUT NOCOPY VARCHAR2
);


--
-- Utility function to gather all interaction attributes from xml.
--
-- Parameters
--
--  int_elem              - IN  - dbms_xmldom.DomElement, with xml data
--  p_bulk_interaction_id - IN  - self explanatory
--  p_bulk_writer_code    - IN  - self explanatory
--  p_bulk_batch_type     - IN  - self explanatory
--  p_bulk_batch_id       - IN  - self explanatory
--  int_rec               - OUT - this is the return interaction record
--  x_ret_status          - OUT - self explanatory
--  x_ret_msg             - OUT - self explanatory
--
PROCEDURE GATHER_INT_ATTR
(
  int_elem                IN            dbms_xmldom.DomElement,
  p_bulk_interaction_id   IN            NUMBER,
  p_bulk_writer_code      IN            VARCHAR2,
  p_bulk_batch_type       IN            VARCHAR2,
  p_bulk_batch_id         IN            NUMBER,
  x_int_rec               IN OUT NOCOPY JTF_IH_PUB.INTERACTION_REC_TYPE,
  x_ret_status            IN OUT NOCOPY VARCHAR2,
  x_ret_msg               IN OUT NOCOPY VARCHAR2
);

--
-- Utility function to gather all interaction attributes from xml.
--
-- Parameters
--
--  int_node              - IN  - dbms_xmldom.DomNode, with interaction xml data
--  p_bulk_writer_code    - IN  - self explanatory
--  p_bulk_batch_type     - IN  - self explanatory
--  p_bulk_batch_id       - IN  - self explanatory
--  p_bulk_interaction_id - IN  - self explanatory
--  p_error_msg           - IN  - message describing what failed
--  p_ret_msg             - IN  - message describing underlying cause
--
FUNCTION LOG_BULK_ERROR
(
  p_int_node            IN dbms_xmldom.DOMNode,
  p_bulk_writer_code    IN VARCHAR2,
  p_bulk_batch_type     IN VARCHAR2,
  p_bulk_batch_id       IN NUMBER,
  p_bulk_interaction_id IN NUMBER,
  p_error_msg           IN VARCHAR2,
  p_ret_msg             IN VARCHAR2
) RETURN VARCHAR2;

--
-- Version 2 - takes IH_BULK_OBJ
-- Utility function to gather all interaction attributes from xml.
--
-- Parameters
--
--  p_bulk_writer_code          - IN  - self explanatory
--  p_bulk_batch_type           - IN  - self explanatory
--  p_bulk_batch_id             - IN  - self explanatory
--  p_bulk_interaction_id       - IN  - self explanatory
--  p_bulk_interaction_request  - IN  - self explanatory
--  p_error_msg                 - IN  - message describing what failed
--  p_ret_msg                   - IN  - message describing underlying cause
--
FUNCTION LOG_BULK_ERROR
(
  p_bulk_writer_code          IN VARCHAR2,
  p_bulk_batch_type           IN VARCHAR2,
  p_bulk_batch_id             IN NUMBER,
  p_bulk_interaction_id       IN NUMBER,
  p_bulk_interaction_request  IN CLOB,
  p_error_msg                 IN VARCHAR2,
  p_ret_msg                   IN VARCHAR2
) RETURN VARCHAR2;

--
-- This procedure attempts to perform crash recovery
--
-- Parameters - none
--
PROCEDURE PERFORM_CRASH_RECOVERY;

--
-- Utility procedure to do logging work in case of an unknown exception.
--
-- Purpose - to replace common code in various routines
--
-- Parameters -
-- p_proc_name IN VARCHAR2  Procedure name where the exception happenned
--
PROCEDURE LOG_EXC_OTHERS (p_proc_name IN VARCHAR2);

END JTF_IH_BULK;

 

/
