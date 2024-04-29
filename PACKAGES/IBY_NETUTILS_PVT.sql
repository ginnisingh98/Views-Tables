--------------------------------------------------------
--  DDL for Package IBY_NETUTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_NETUTILS_PVT" AUTHID CURRENT_USER AS
/* $Header: ibynutls.pls 120.4.12010000.1 2008/07/28 05:41:21 appldev ship $ */

  -- network path separator character
  G_NET_PATH_SEP CONSTANT VARCHAR2(1) := '/';
  -- file protocol
  G_FILE_PROTOCOL CONSTANT VARCHAR2(10) := 'file:';


  -- profile option for the no proxy domain
  G_PROFILE_NO_PROXY CONSTANT VARCHAR2(50) := 'IBY_NOPROXY_DOMAIN';
  -- profile option for the HTTP proxy host
  G_PROFILE_HTTP_PROXY CONSTANT VARCHAR2(50) := 'IBY_HTTP_PROXY';


-- Utility Table Type
/* Note: This is a utility table to be used for storing names,
   values of name-value pairs. */
TYPE v240_tbl_type IS TABLE of VARCHAR2(240) INDEX BY BINARY_INTEGER;

-- Exception thrown when there is error encoding/decoding
-- from different character sets
--
encoding_error EXCEPTION;

-- Defines proxy settings for a HTTP request
--
PROCEDURE set_proxy(p_url IN VARCHAR2);

--
-- Name: decode_url_chars
-- Args: p_string => the encoded string ,
--       p_local_nls => the NLSLang for the local environment/db
--       p_remote_nls => the remote machine's NLSLang value
--
-- Return: The decoded string
--
FUNCTION decode_url_chars (p_string     IN VARCHAR2,
                           p_local_nls  IN VARCHAR2 DEFAULT NULL,
                           p_remote_nls IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

--
-- Name: escape_url_chars
-- Args: p_string => string value to encode ,
--       p_local_nls => the NLSLang for the local environment/db
--       p_remote_nls => the remote machine's NLSLang value
--
-- Return: the URL encoded form of the string value
--
-- Exceptions: throws the encoding_error exception if some error
--             during encoding
--
FUNCTION escape_url_chars (p_string IN VARCHAR2,
                           p_local_nls IN VARCHAR2 DEFAULT NULL,
                           p_remote_nls IN VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

--
--    Name: unpack_results_url
--
--    UTILITY PROCEDURE #1: UNPACK_RESULTS_URL
--    PARSER Procedure to take in given l_string in html file format,
--    parse l_string, and store the Name-Value pairs in l_names and l_values.
--    For example, if OapfPrice Name-Value pairs exist in l_string, it would be
--    stored as l_names(i) := 'OapfPrice' and l_values(i) := '17.00'.
--
--    NOTE: This procedure logic is exactly similar to the iPayment 3i version
--          of procedure with minor enhancements and bug fixes.

PROCEDURE unpack_results_url(p_string     IN  VARCHAR2,
                             x_names      OUT NOCOPY v240_tbl_type,
                             x_values     OUT NOCOPY v240_tbl_type,
                             x_status     OUT NOCOPY NUMBER,
                             x_errcode    OUT NOCOPY NUMBER,
                             x_errmessage OUT NOCOPY VARCHAR2
                             ) ;


--
--      Name: post_request
--      Use this to send large POST messages and responses.
--
--      UTILITY PROCEDURE #7: SEND_REQUEST
--      Procedure to call HTTP_UTIL.SEND_REQUEST and handle exceptions thrown by it
--
--
PROCEDURE post_request(p_url       IN VARCHAR2,
                        p_postbody  IN CLOB,
                        x_names      OUT NOCOPY v240_tbl_type,
                        x_values     OUT NOCOPY v240_tbl_type,
                        x_status     OUT NOCOPY NUMBER,
                        x_errcode    OUT NOCOPY NUMBER,
                        x_errmessage OUT NOCOPY VARCHAR2
                       );

--
--      Name: post_request
--
--      UTILITY PROCEDURE #7: SEND_REQUEST
--      Procedure to call HTTP_UTIL.SEND_REQUEST and handle exceptions thrown by it
--
--
PROCEDURE post_request(p_url       IN VARCHAR2,
                       p_postbody  IN VARCHAR2,
                       x_htmldoc OUT NOCOPY VARCHAR2
                        );

--
--   Name : check_mandatory
--
--
--
--
PROCEDURE check_mandatory (p_name    IN     VARCHAR2,
                             p_value   IN     VARCHAR2,
                             p_url     IN OUT NOCOPY VARCHAR2,
			     p_local_nls IN VARCHAR2 DEFAULT NULL,
			     p_remote_nls IN VARCHAR2 DEFAULT NULL
                             );

--
--  Name : check_optional
--
--
--
--
PROCEDURE check_optional (p_name  IN     VARCHAR2,
                            p_value IN     VARCHAR2,
                            p_url   IN OUT NOCOPY VARCHAR2,
			    p_local_nls IN VARCHAR2 DEFAULT NULL,
			    p_remote_nls IN VARCHAR2 DEFAULT NULL
                            ) ;

--
-- Name: GET_BASEURL
-- Procedure to retrieve the iPayment ECAPP BASE URL
--
PROCEDURE get_baseurl(x_baseurl OUT NOCOPY VARCHAR2);

--
-- Name: GET_LOCAL_NLS
-- Function returns the local (i.e. database) characterset.
--
FUNCTION get_local_nls RETURN VARCHAR2;

--
-- Name: path_to_url
-- Function returns a given path name as 'file:' type url
--
FUNCTION path_to_url(p_path IN VARCHAR2) RETURN VARCHAR2;

END IBY_NETUTILS_PVT;

/
