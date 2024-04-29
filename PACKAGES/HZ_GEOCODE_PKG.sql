--------------------------------------------------------
--  DDL for Package HZ_GEOCODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEOCODE_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHGEOCS.pls 115.8 2002/12/20 22:59:32 rrangan noship $*/

  g_max_rows        NUMBER := 20;

  TYPE loc_array IS VARRAY(20) OF hz_location_v2pub.location_rec_type;
  TYPE array_t IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

  --------------------------------------------
  -- declaration of global variables and types
  --------------------------------------------
  g_pkg_name     CONSTANT VARCHAR2(30) := 'HZ_GEOCODE_PKG';
  g_debug_count           NUMBER := 0;
  g_debug                 BOOLEAN := FALSE;
  g_good         CONSTANT VARCHAR2(30) := 'GOOD';
  g_dirty        CONSTANT VARCHAR2(30) := 'DIRTY';
  g_error        CONSTANT VARCHAR2(30) := 'ERROR';
  g_multimatch   CONSTANT VARCHAR2(30) := 'MULTIMATCH';
  g_noexactmatch CONSTANT VARCHAR2(30) := 'NOEXACTMATCH';
  g_processing   CONSTANT VARCHAR2(30) := 'PROCESSING';

  -------------------------------------------------------
  -- RETURN Y if nls_numeric_character = '.,' US standard
  --        N otherwise
  -------------------------------------------------------
  FUNCTION is_nls_num_char_pt_com RETURN VARCHAR2;

  --
  -- PUBLIC FUNCTION
  --   remove_whitespace
  --
  -- DESCRIPTION
  --   Remove whitespace from a string
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- MODIFICATION HISTORY
  --
  --   02-28-2002    Joe del Callar      Created.
  --
  FUNCTION remove_whitespace (p_str IN VARCHAR2) RETURN VARCHAR2;

  --
  -- PUBLIC FUNCTION
  --   in_bypass_list
  --
  -- DESCRIPTION
  --   Returns 'Y' if the argument p_url_target is in p_exclusion_list, 'N'
  --   otherwise.  Used to determine whether or not to use a proxy.  This
  --   functionality can only be used with fixed-length character set
  --   exclusion lists and targets, which is okay since these are URLs.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_target_url
  --     p_exclusion_list
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   03-27-2002    J. del Callar   Created.
  --
  FUNCTION in_bypass_list (
    p_url_target        IN      VARCHAR2,
    p_exclusion_list    IN      VARCHAR2
  ) RETURN BOOLEAN;

  --
  -- PUBLIC PROCEDURE
  --   get_spatial_coords
  --
  -- DESCRIPTION
  --   Build the xml request for n locations
  --   Post the Xml request
  --   Split the Response into individual responses
  --   Parse and update hz_locations with the responses
  --   If error Then x_return_status = E
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_name
  --     p_http_ad
  --     p_proxy
  --     p_port
  --     p_retry
  --     p_init_msg_list
  --   IN/OUT:
  --     p_loc_array
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be FND_API.G_RET_STS_SUCCESS (success),
  --                          FND_API.G_RET_STS_ERROR (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   01-09-2002    Herve Yu        Created.
  --   01-28-2002    Joe del Callar  Modified to return the geometry in the
  --                                 loc_array structure in order to facilitate
  --                                 integration with HR.
  --

  PROCEDURE get_spatial_coords (
    p_loc_array     IN OUT NOCOPY loc_array,
    p_name          IN     VARCHAR2 DEFAULT NULL,
    p_http_ad       IN     VARCHAR2,
    p_proxy         IN     VARCHAR2 DEFAULT NULL,
    p_port          IN     NUMBER   DEFAULT NULL,
    p_retry         IN     NUMBER   DEFAULT 3,
    p_init_msg_list IN     VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status OUT NOCOPY    VARCHAR2,
    x_msg_count     OUT NOCOPY    NUMBER,
    x_msg_data      OUT NOCOPY    VARCHAR2
  );

END hz_geocode_pkg;

 

/
