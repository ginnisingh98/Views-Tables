--------------------------------------------------------
--  DDL for Package FND_RT_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_RT_REQUEST" AUTHID CURRENT_USER AS
/* $Header: AFRTREQS.pls 115.1 99/07/16 23:27:30 porting sh $ */

    PROCEDURE get_test_id(testid IN OUT INTEGER);
    -- Get a unique value of test_id that can be used
    -- to uniquely identify a regression test.
    -- This procedure uses the FND_RT_REQUESTS_S sequence
    -- to generate unique values.

    PROCEDURE log_request(testid 	IN INTEGER,
			  requestid    IN INTEGER);
    -- Create a new record in the FND_RT_REQUESTS table using
    -- the given test_id and request_id.

    PROCEDURE search_requests(testid 	IN INTEGER,
                              timeout   IN INTEGER);
    -- Search for all the child requests in FND_CONCURRENT_REQUESTS table
    -- for all the parent in the testid
    -- Insert all the children requests into FND_RT_REQUESTS table

    PROCEDURE get_request(testid 	IN INTEGER,
			 requestid     OUT INTEGER);
    -- Get the next request id for the given test_id
    -- and delete the record from the FND_RT_REQUESTS table.
END fnd_rt_request;

 

/
