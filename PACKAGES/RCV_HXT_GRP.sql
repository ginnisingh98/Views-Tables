--------------------------------------------------------
--  DDL for Package RCV_HXT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_HXT_GRP" AUTHID CURRENT_USER AS
/* $Header: RCVGHXTS.pls 120.1 2005/06/14 18:12:04 wkunz noship $ */

--
--    API name    : Purchasing_Retrieval_Process
--    Type        : Group
--    Function    : Identifies the retrieval process to the Generic Retrieval
--                  so that the latter knows what attributes to populate
--    Pre-reqs    :
--    Parameters  :
--    IN          :
--    OUT         :
--    Version     : Initial version     1.0
--    Notes       : Note text
--
FUNCTION Purchasing_Retrieval_Process RETURN VARCHAR2;

--
--    API name    : Update_Timecard
--    Type        : Group
--    Function    : Callback to update timecard attributes after
--                  the user submits a timecard. Conforms to OTL-defined
--                  interface.
--    Pre-reqs    : popo.odf  115.62
--                  rvtxi.odf 115.28
--    Parameters  :
--    IN          : p_operation            IN VARCHAR2  Required
--    OUT         :
--    Version     : Initial version     1.0
--    Notes       : Note text
--
PROCEDURE Update_Timecard( p_operation IN VARCHAR2 );

--
--    API name    : Validate_Timecard
--    Type        : Group
--    Function    : Callback to validate timecard attributes after
--                  the user submits a timecard
--    Pre-reqs    : popo.odf  115.62
--                  rvtxi.odf 115.28
--    Parameters  :
--    IN          : p_api_version          IN NUMBER    Required
--                  p_init_msg_list        IN VARCHAR2  Optional
--                         Default = FND_API.G_FALSE
--                  p_commit               IN VARCHAR2  Optional
--                         Default = FND_API.G_FALSE
--                  p_validation_level     IN NUMBER    Optional
--                         Default = FND_API.G_VALID_LEVEL_FULL
--                  parameter1
--                  parameter2
--    OUT         : x_return_status        OUT    VARCHAR2(1)
--                  x_msg_count            OUT    NUMBER
--                  x_msg_data             OUT    VARCHAR2(2000)
--    Version     : Initial version     1.0
--
--    Notes       : Note text
--
PROCEDURE Validate_Timecard( p_operation IN VARCHAR2 );

--
--    API name    : Validate_Block
--    Type        : Group
--    Function    : Callback to validate the timecard attributes of
--                  one building block after the user submits a timecard
--    Pre-reqs    : popo.odf  115.62
--                  rvtxi.odf 115.28
--    Parameters  :
--    IN          : p_api_version          IN NUMBER    Required
--                  p_init_msg_list        IN VARCHAR2  Optional
--                         Default = FND_API.G_FALSE
--                  p_commit               IN VARCHAR2  Optional
--                         Default = FND_API.G_FALSE
--                  p_validation_level     IN NUMBER    Optional
--                         Default = FND_API.G_VALID_LEVEL_FULL
--                  parameter1
--                  parameter2
--    OUT         : x_return_status        OUT    VARCHAR2(1)
--                  x_msg_count            OUT    NUMBER
--                  x_msg_data             OUT    VARCHAR2(2000)
--    Version     : Initial version     1.0
--
--    Notes       : Note text
--
PROCEDURE Validate_Block
( p_effective_date            IN DATE
, p_type                      IN VARCHAR2
, p_measure                   IN NUMBER
, p_unit_of_measure           IN VARCHAR2
, p_start_time                IN DATE
, p_stop_time                 IN DATE
, p_parent_building_block_id  IN NUMBER
, p_parent_building_block_ovn IN NUMBER
, p_scope                     IN VARCHAR2
, p_approval_style_id         IN NUMBER
, p_approval_status           IN VARCHAR2
, p_resource_id               IN NUMBER
, p_resource_type             IN VARCHAR2
, p_comment_text              IN VARCHAR2
);

--
--    API name    : Retrieve_Timecards
--    Type        : Group
--    Function    : Program to retrieve timecards relevant to Receiving
--    Pre-reqs    : popo.odf  115.62
--                  rvtxi.odf 115.28
--    Parameters  :
--    Version     : Initial version     1.0
--
--    Notes       : Note text
--
PROCEDURE Retrieve_Timecards
( errbuf               OUT NOCOPY VARCHAR2
, retcode              OUT NOCOPY VARCHAR2
, p_vendor_id          IN         NUMBER   := NULL
, p_start_date         IN         VARCHAR2 := NULL
, p_end_date           IN         VARCHAR2 := NULL
, p_receipt_date       IN         VARCHAR2 := NULL
);

END;


 

/
