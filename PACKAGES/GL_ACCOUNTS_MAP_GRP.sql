--------------------------------------------------------
--  DDL for Package GL_ACCOUNTS_MAP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ACCOUNTS_MAP_GRP" AUTHID CURRENT_USER as
/* $Header: glgcmaps.pls 120.4.12010000.1 2008/07/28 13:22:35 appldev ship $ */

--
-- Package
--   GL_ACCOUNTS_MAP_GRP
-- Purpose
--   API for Chart of Accounts Mapping
-- History
--   08-MAY-2002  M. Ward          Created.
--

  -- This exception is raised when there is no mapping with the mapping name
  -- specified in the parameter of the map procedure
  GL_INVALID_MAPPING_NAME EXCEPTION;

  -- This exception is raised when the mapping is disabled because the
  -- current date is outside the active date range for the mapping
  GL_DISABLED_MAPPING EXCEPTION;

  -- This exception is raised when the mapping rules are incorrectly defined
  GL_INVALID_MAPPING_RULES EXCEPTION;

  -- This exception is raised when any other error occurs
  GL_MAP_UNEXPECTED_ERROR EXCEPTION;


  -- The source chart of accounts has no balancing segment
  GL_BSV_MAP_NO_SOURCE_BAL_SEG EXCEPTION;

  -- The target chart of accounts has no balancing segment
  GL_BSV_MAP_NO_TARGET_BAL_SEG EXCEPTION;

  -- Raised when there is no segment mapping for the balancing segment
  GL_BSV_MAP_NO_SEGMENT_MAP EXCEPTION;

  -- Raised when there is no single value to assign to the balancing segment
  GL_BSV_MAP_NO_SINGLE_VALUE EXCEPTION;

  -- Raised when there is no derive-from segment
  GL_BSV_MAP_NO_FROM_SEGMENT EXCEPTION;

  -- Raised when the derive-from segment is not the balancing segment
  GL_BSV_MAP_NOT_BSV_DERIVED EXCEPTION;

  -- This exception is raised when the mapping setup information could not
  -- be obtained
  GL_BSV_MAP_SETUP_ERROR EXCEPTION;

  -- This exception is raised when the mapping could not be performed
  GL_BSV_MAP_MAPPING_ERROR EXCEPTION;

  -- This exception is raised when an unexpected error occurs in getting the
  -- BSV mapping information
  GL_BSV_MAP_UNEXPECTED_ERROR EXCEPTION;


  --
  -- Procedure
  --   map
  -- Purpose
  --   This retrieves the code combinations from the FROM_CCID column of the
  --   GL_ACCOUNTS_MAP_INTERFACE table. Then uses the chart of accounts
  --   mapping specified in the argument to map these code combinations and
  --   populate the TO_CCID AND TO_SEGMENT<x> columns. This will create new
  --   code combinations if create_ccid is true. If not, this will leave
  --   TO_CCID null for all segment-mapped accounts.
  -- History
  --   09-MAY-2002  M. Ward    Created
  -- Arguments
  --   mapping_name		Name of the mapping to use
  --   create_ccid		Whether or not to create new code combinations
  --				for the target chart of accounts
  --   debug			Whether or not to print debug messages
  -- Example
  --   GL_ACCOUNTS_MAP_GRP.map(
  --      'MY_MAPPING',
  --      TRUE);
  -- Notes
  --
  PROCEDURE map(mapping_name	IN VARCHAR2,
		create_ccid	IN BOOLEAN DEFAULT TRUE,
		debug           IN BOOLEAN DEFAULT FALSE
               );


  --
  -- Procedure
  --   map
  -- Purpose
  --   This retrieves the code combinations from the FROM_CCID column of the
  --   GL_ACCOUNTS_MAP_INTERFACE table. Then uses the chart of accounts
  --   mapping specified in the argument to map these code combinations and
  --   populate the TO_CCID AND TO_SEGMENT<x> columns. This will create new
  --   code combinations if create_ccid is true. If not, this will leave
  --   TO_CCID null for all segment-mapped accounts. This adheres to the Oracle
  --   Applications Business Object API Coding Standards.
  -- History
  --   14-JUN-2002  M. Ward    Created
  -- Arguments
  --   p_api_version		API version string
  --   p_init_msg_list		whether or not to initialize the message list
  --   x_return_status		Success, error, or unexpected error
  --   x_msg_count		number of messages in the message list
  --   x_msg_data		if there is only one message in the message
  --				list, gives that message.
  --   p_mapping_name		Name of the mapping to use
  --   p_create_ccid		Whether or not to create new code combinations
  --				for the target chart of accounts
  --   p_debug			Whether or not to print debug messages
  -- Example
  --   GL_ACCOUNTS_MAP_GRP.Map_Account(
  --      p_mapping_name	=> 'MY_MAPPING',
  --      p_create_ccid		=> FND_API.G_TRUE);
  -- Notes
  --
  PROCEDURE Map_Account(p_api_version	IN NUMBER,
                        p_init_msg_list	IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        x_return_status	OUT NOCOPY VARCHAR2,
                        x_msg_count	OUT NOCOPY NUMBER,
                        x_msg_data	OUT NOCOPY VARCHAR2,
                        p_mapping_name	IN VARCHAR2,
                        p_create_ccid	IN VARCHAR2 DEFAULT FND_API.G_TRUE,
                        p_debug		IN VARCHAR2 DEFAULT FND_API.G_FALSE
                       );

  --
  -- Procedure
  --   map_bsvs
  -- Purpose
  --   This gets the list of source BSV values from the global temporary table
  --   GL_ACCOUNTS_MAP_BSVS_GT and derives the target BSV values for those,
  --   populating the target column of that global temporary table. If the
  --   target BSV derivation is not a single value and is not derived from the
  --   source chart of account's BSV, an error is raised.
  -- History
  --   13-MAY-2004  M. Ward    Created
  -- Arguments
  --   p_mapping_name		Name of the mapping to use
  --   p_debug			Whether or not to print debug messages
  -- Example
  --   GL_ACCOUNTS_MAP_GRP.map_bsvs
  --     (p_mapping_name => 'MY_MAPPING');
  -- Notes
  --
  PROCEDURE map_bsvs(	p_mapping_name	IN VARCHAR2,
			p_debug		IN BOOLEAN);

  --
  -- Procedure
  --   Populate_BSV_Targets
  -- Purpose
  --   This gets the list of source BSV values from the global temporary table
  --   GL_ACCOUNTS_MAP_BSVS_GT and derives the target BSV values for those,
  --   populating the target column of that global temporary table. If the
  --   target BSV derivation is not a single value and is not derived from the
  --   source chart of account's BSV, an error is raised. This adheres to the
  --   Oracle Applications Business Object API Coding Standards.
  -- History
  --   12-MAY-2004  M. Ward    Created
  -- Arguments
  --   p_api_version		API version string
  --   p_init_msg_list		whether or not to initialize the message list
  --   x_return_status		Success, error, or unexpected error
  --   x_msg_count		number of messages in the message list
  --   x_msg_data		if there is only one message in the message
  --				list, gives that message.
  --   p_mapping_name		Name of the mapping to use
  --   p_debug			Whether or not to print debug messages
  -- Example
  --   GL_ACCOUNTS_MAP_GRP.Populate_BSV_Targets
  --     (p_mapping_name => 'MY_MAPPING');
  -- Notes
  --
  PROCEDURE Populate_BSV_Targets
	(p_api_version		IN NUMBER,
	 p_init_msg_list	IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	 x_return_status	OUT NOCOPY VARCHAR2,
	 x_msg_count		OUT NOCOPY NUMBER,
	 x_msg_data		OUT NOCOPY VARCHAR2,
	 p_mapping_name		IN VARCHAR2,
	 p_debug		IN VARCHAR2 DEFAULT FND_API.G_FALSE
	);


  --
  -- Procedure
  --   map_qualified_segment
  -- Purpose
  --   This gets the list of source segment values from the global temporary
  --   GL_ACCOUNTS_MAP_BSVS_GT and derives the target segment values for those,
  --   populating the target column of that global temporary table. If the
  --   target segment derivation is not a single value and is not derived from
  --   the source chart of account's segment with the same qualifier as the
  --   target, an error is raised.
  -- History
  --   10-JAN-2005  M. Ward    Created
  -- Arguments
  --   p_mapping_name		Name of the mapping to use
  --   p_qualifier		Segment qualifier
  --   p_debug			Whether or not to print debug messages
  -- Example
  --   GL_ACCOUNTS_MAP_GRP.map_qualified_segment
  --     (p_mapping_name => 'MY_MAPPING');
  -- Notes
  --
  PROCEDURE map_qualified_segment(	p_mapping_name	IN VARCHAR2,
					p_qualifier	IN VARCHAR2,
					p_debug		IN BOOLEAN);

  --
  -- Procedure
  --   Populate_Qual_Segment_Targets
  -- Purpose
  --   This gets the list of source segment values from the global temporary
  --   GL_ACCOUNTS_MAP_BSVS_GT and derives the target segment values for those,
  --   populating the target column of that global temporary table. If the
  --   target segment derivation is not a single value and is not derived from
  --   the source chart of account's segment with the same qualifier as the
  --   target, an error is raised. This adheres to the Oracle Applications
  --   Business Object API Coding Standards.
  -- History
  --   10-JAN-2005  M. Ward    Created
  -- Arguments
  --   p_api_version		API version string
  --   p_init_msg_list		whether or not to initialize the message list
  --   x_return_status		Success, error, or unexpected error
  --   x_msg_count		number of messages in the message list
  --   x_msg_data		if there is only one message in the message
  --				list, gives that message.
  --   p_mapping_name		Name of the mapping to use
  --   p_qualifier		Segment qualifier
  --   p_debug			Whether or not to print debug messages
  -- Example
  --   GL_ACCOUNTS_MAP_GRP.Populate_Qual_Segment_Targets
  --     (p_mapping_name => 'MY_MAPPING');
  -- Notes
  --
  PROCEDURE Populate_Qual_Segment_Targets
	(p_api_version		IN NUMBER,
	 p_init_msg_list	IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	 x_return_status	OUT NOCOPY VARCHAR2,
	 x_msg_count		OUT NOCOPY NUMBER,
	 x_msg_data		OUT NOCOPY VARCHAR2,
	 p_mapping_name		IN VARCHAR2,
	 p_qualifier		IN VARCHAR2,
	 p_debug		IN VARCHAR2 DEFAULT FND_API.G_FALSE
	);


END GL_ACCOUNTS_MAP_GRP;

/
