--------------------------------------------------------
--  DDL for Package FND_HTTP_TICKET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_HTTP_TICKET" AUTHID CURRENT_USER AS
/* $Header: AFSTCKTS.pls 120.1 2005/07/02 04:18:33 appldev noship $ */
--
--  schema information
--
--  Table to store short-lifespan and one-time-use tickets.
--  Since the table is only accessed by TICKET, or by a full scan,
--  it's an index-organized table to reduce storage overhead.
--
-- create table FND_HTTP_TICKETS
--             (
--             TICKET     raw(16)                          not null,
--             START_DATE date            default SYSDATE  not null,
--             END_DATE   date                                     ,
--             OPERATION  varchar2(255)                            ,
--             ARGUMENT   varchar2(4000)                           ,
--             constraint FND_HTTP_TICKETS_PK
--                primary key (TICKET)
--             ) organization index;
-- TICKET     16-byte raw value holding a 128-bit cryptographically secure
--            random number that will be used as the ticket value.
-- START_DATE The date/time that the ticket was generated (defaults to
--            SYSDATE).
-- END_DATE   An optional date/time that the ticket will expire.
-- OPERATION  A 255-byte string to hold as a payload an optional operation
--            that is correlated with the ticket (to prevent misuse of
--            the ticket for an operation other than that intended by the
--            issuer).
-- ARGUMENT   A 4000-byte string to hold as a payload an optional argument
--            or arguments to the operation (to prevent misuse of the
--            ticket against a target object or parameters other than those
--            intended by the issuer.
--


--
-- Create a ticket for use with an HTTP operation.  Optionally store
-- a string describing the operation (up to 255 bytes), and an argument
-- string (up to 4000 bytes).  Optionally specify a lifespan for the
-- ticket (in seconds).  Returns a 16-byte secure random raw value, or
-- null upon failure.
--
  function CREATE_TICKET(P_OPERATION in varchar2 default null,
                         P_ARGUMENT  in varchar2 default null,
                         P_LIFESPAN  in number   default 60)
    return raw;
--
-- Version of create ticket that returns a URL-compatible string that
-- is equivalent to the raw value.
--
  function CREATE_TICKET_STRING(P_OPERATION in varchar2 default null,
                                P_ARGUMENT  in varchar2 default null,
                                P_LIFESPAN  in number   default 60)
    return varchar2;
--
-- Set a ticket for use with an HTTP service.  Updates the existing
-- row for this service with a new ticket value.  Returns both the new
-- and the previous ticket values concatenated into a 32-byte raw.
-- Returns null on any failure.
--
  function SET_SERVICE_TICKET(P_SERVICE in varchar2) return raw;
--
-- Gets the ticket for use with an HTTP service.
-- Returns a pair of 16-byte secure random raw values concatenated into
-- a 32-byte raw, or null upon failure.  The first 16 bytes are the
-- current ticket value, and the last 16 bytes are the previous ticket
-- value.
--
  function GET_SERVICE_TICKET(P_SERVICE in varchar2)
    return raw;
--
-- Version of get service ticket that returns a URL-compatible string
-- that is equivalent to the raw value.
--
  function GET_SERVICE_TICKET_STRING(P_SERVICE in varchar2)
    return varchar2;
--
-- Compare two service ticket pairs.
-- Each ticket pair is passed as a 32-byte raw.  If either 16-byte portion
-- of the first pair matches either 16-byte portion of the second pair,
-- returns true, otherwise returns false.
--
  function COMPARE_SERVICE_TICKETS(P_TICKET1 in raw, P_TICKET2 in raw)
    return boolean;
--
-- String form of ticket pair comparison.
-- Returns true for a match, false otherwise.
--
  function COMPARE_SERVICE_TICKET_STRINGS(P_TICKET1 in varchar2,
                                          P_TICKET2 in varchar2)
    return boolean;
--
-- Check an HTTP ticket to see if its valid.  If so, any stored
-- operation and/or argument string(s) are returned in the output
-- arguments.  The returned value is null for a failure to find the
-- ticket, false if the ticket still exists but has expired, and true
-- otherwise (including the case where no lifespan was specified).
--
  function CHECK_TICKET(P_TICKET    in  raw,
                        P_OPERATION out nocopy varchar2,
                        P_ARGUMENT  out nocopy varchar2)
    return boolean;
--
-- Simpler form of check that omits the output buffers.
--
  function CHECK_TICKET(P_TICKET in raw) return boolean;
--
-- Version of check ticket that takes a URL string argument.
--
  function CHECK_TICKET_STRING(P_TICKET    in  varchar2,
                               P_OPERATION out nocopy varchar2,
                               P_ARGUMENT  out nocopy varchar2)
    return boolean;
--
-- Simpler version of check ticket that takes a URL string argument.
--
  function CHECK_TICKET_STRING(P_TICKET in varchar2) return boolean;
--
-- Update a ticket's payload columns,
-- return true if successful, false if expired
--
  function UPDATE_TICKET(P_TICKET    in raw,
                         P_OPERATION in varchar2,
                         P_ARGUMENT  in varchar2)
    return boolean;
--
-- Version of update ticket that takes a URL string ticker.
--
  function UPDATE_TICKET_STRING(P_TICKET    in varchar2,
                                P_OPERATION in varchar2,
                                P_ARGUMENT  in varchar2)
    return boolean;
--
-- Check a one-time-use ticket; destroys the ticket if found,
-- returns results as per CHECK_TICKET.
--
  function CHECK_ONETIME_TICKET(P_TICKET    in  raw,
                                P_OPERATION out nocopy varchar2,
                                P_ARGUMENT  out nocopy varchar2)
    return boolean;
--
-- Version of the one-time-use ticket check that takes a URL string ticket.
--
  function CHECK_ONETIME_TICKET_STRING(P_TICKET    in  varchar2,
                                       P_OPERATION out nocopy varchar2,
                                       P_ARGUMENT  out nocopy varchar2)
    return boolean;
--
-- Destroy an HTTP ticket, delete it from the table.
--
  procedure DESTROY_TICKET(P_TICKET in raw);
--
-- Version of destroy ticket that takes a URL string.
--
  procedure DESTROY_TICKET_STRING(P_TICKET in varchar2);
--
-- Remove all expired tickets from the table.  Optionally can also
-- remove all tickets that have aged beyond the specified lifespan
-- (in seconds).
--
  procedure PURGE_TICKETS(P_MAX_LIFESPAN in number default null);
--
end FND_HTTP_TICKET;

 

/
