--------------------------------------------------------
--  DDL for Package EPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EPS" AUTHID CURRENT_USER AS
/* $Header: epsusers.pls 115.2 2002/11/08 19:08:01 dkang ship $ */

--
-- Create the Generic object an a list type
--
/*
TYPE EPS_express_t IS RECORD (c0         VARCHAR2(2000),
                                       c1         VARCHAR2(2000),
                                       c2         VARCHAR2(2000),
                                       c3         VARCHAR2(2000),
                                       c4         VARCHAR2(2000),
                                       c5         VARCHAR2(2000),
                                       c6         VARCHAR2(2000),
                                       c7         VARCHAR2(2000),
                                       c8         VARCHAR2(2000),
                                       c9         VARCHAR2(2000),
                                       c10        VARCHAR2(2000),
                                       c11        VARCHAR2(2000),
                                       c12        VARCHAR2(2000),
                                       c13        VARCHAR2(2000),
                                       c14        VARCHAR2(2000),
                                       c15        VARCHAR2(2000),
                                       c16        VARCHAR2(2000),
                                       c17        VARCHAR2(2000),
                                       c18        VARCHAR2(2000),
                                       c19        VARCHAR2(2000),
                                       c20        VARCHAR2(2000),
                                       c21        VARCHAR2(2000),
                                       c22        VARCHAR2(2000),
                                       c23        VARCHAR2(2000),
                                       c24        VARCHAR2(2000),
                                       c25        VARCHAR2(2000),
                                       c26        VARCHAR2(2000),
                                       c27        VARCHAR2(2000),
                                       c28        VARCHAR2(2000),
                                       c29        VARCHAR2(2000),
                                       c30        VARCHAR2(2000),
                                       c31        VARCHAR2(2000),
                                       c32        VARCHAR2(2000),
                                       c33        VARCHAR2(2000),
                                       c34        VARCHAR2(2000),
                                       c35        VARCHAR2(2000),
                                       c36        VARCHAR2(2000),
                                       c37        VARCHAR2(2000),
                                       c38        VARCHAR2(2000),
                                       c39        VARCHAR2(2000));

TYPE EPS_express_list_t IS TABLE OF EPS_express_t;
*/
  --
  -- Query express
  --
  -- Note: PL/SQL functions embedded in a SQL statement cannot update the database.
  --
  FUNCTION query (express_server VARCHAR2,
                  qry0  VARCHAR2,
                  qry1  VARCHAR2,
                  qry2  VARCHAR2,
                  qry3  VARCHAR2,
                  qry4  VARCHAR2,
                  qry5  VARCHAR2,
                  qry6  VARCHAR2,
                  qry7  VARCHAR2,
                  qry8  VARCHAR2,
                  qry9  VARCHAR2)
           RETURN EPS_express_list_t;
  PRAGMA RESTRICT_REFERENCES (query, WNDS, WNPS);


  --
  --   Returns an error string for an Express DLL callout failure code
  --

  FUNCTION  getErrorMsg(status  NUMBER)
            RETURN VARCHAR2 ;
  PRAGMA RESTRICT_REFERENCES (getErrorMsg, WNDS, WNPS);



  --
  -- Express DLL callout functions
  --
  --
  -- OCI Callout - XPPrepare - Prepare an Express Query
  --
  -- Return 0 SUCCESS 1 FAIL
  --
  FUNCTION XPPrepare(in_report_id      IN NATURAL,
                     in_express_server IN VARCHAR2,
                     in_qry            IN VARCHAR2)
                    RETURN NATURAL;
  PRAGMA RESTRICT_REFERENCES (XPPrepare, WNDS, WNPS);

  --
  -- OCI Callout - XPFetch - Fetch a row from an Express Query
  --
  -- Return 0 SUCCESS 1 FAIL
  --
  -- Raises exception 1403 (No data found) when called after last
  -- row fetched or if first fetch returns no data.
  --
  FUNCTION XPFetch(in_report_id NATURAL,
                   c0           IN OUT NOCOPY VARCHAR2,
                   c1           IN OUT NOCOPY VARCHAR2,
                   c2           IN OUT NOCOPY VARCHAR2,
                   c3           IN OUT NOCOPY VARCHAR2,
                   c4           IN OUT NOCOPY VARCHAR2,
                   c5           IN OUT NOCOPY VARCHAR2,
                   c6           IN OUT NOCOPY VARCHAR2,
                   c7           IN OUT NOCOPY VARCHAR2,
                   c8           IN OUT NOCOPY VARCHAR2,
                   c9           IN OUT NOCOPY VARCHAR2,
                   c10          IN OUT NOCOPY VARCHAR2,
                   c11          IN OUT NOCOPY VARCHAR2,
                   c12          IN OUT NOCOPY VARCHAR2,
                   c13          IN OUT NOCOPY VARCHAR2,
                   c14          IN OUT NOCOPY VARCHAR2,
                   c15          IN OUT NOCOPY VARCHAR2,
                   c16          IN OUT NOCOPY VARCHAR2,
                   c17          IN OUT NOCOPY VARCHAR2,
                   c18          IN OUT NOCOPY VARCHAR2,
                   c19          IN OUT NOCOPY VARCHAR2,
                   c20          IN OUT NOCOPY VARCHAR2,
                   c21          IN OUT NOCOPY VARCHAR2,
                   c22          IN OUT NOCOPY VARCHAR2,
                   c23          IN OUT NOCOPY VARCHAR2,
                   c24          IN OUT NOCOPY VARCHAR2,
                   c25          IN OUT NOCOPY VARCHAR2,
                   c26          IN OUT NOCOPY VARCHAR2,
                   c27          IN OUT NOCOPY VARCHAR2,
                   c28          IN OUT NOCOPY VARCHAR2,
                   c29          IN OUT NOCOPY VARCHAR2,
                   c30          IN OUT NOCOPY VARCHAR2,
                   c31          IN OUT NOCOPY VARCHAR2,
                   c32          IN OUT NOCOPY VARCHAR2,
                   c33          IN OUT NOCOPY VARCHAR2,
                   c34          IN OUT NOCOPY VARCHAR2,
                   c35          IN OUT NOCOPY VARCHAR2,
                   c36          IN OUT NOCOPY VARCHAR2,
                   c37          IN OUT NOCOPY VARCHAR2,
                   c38          IN OUT NOCOPY VARCHAR2,
                   c39          IN OUT NOCOPY VARCHAR2)
                  RETURN NATURAL;
  PRAGMA RESTRICT_REFERENCES (XPFetch, WNDS, WNPS);


  --
  -- OCI Callout - XPFetchN - Fetch multiple rows from an Express Query
  --
  -- Return 0 SUCCESS 1 FAIL
  --
  -- Raises exception 1403 (No data found) when called after last
  -- row fetched or if first fetch returns no data.
  --
  FUNCTION XPFetchN(in_report_id NATURAL,
                    buffer_size  NATURAL,
                    buffer       IN OUT NOCOPY VARCHAR2,
                    num_cols     OUT NOCOPY NATURAL,
                    num_rows     OUT NOCOPY NATURAL)
                  RETURN NATURAL;
  PRAGMA RESTRICT_REFERENCES (XPFetchN, WNDS, WNPS);


  --
  -- OCI Callout - xrbGetMessage - Get an EPS error message string given
  --                               an error code.
  --
  -- Return 1 SUCCESS 0 FAIL
  --
  FUNCTION xrbGetMessage(msgno      IN NATURAL,
                         buffer     IN OUT NOCOPY VARCHAR2,
                         bufsize    IN NATURAL)
                    RETURN NATURAL;
  PRAGMA RESTRICT_REFERENCES (xrbGetMessage, WNDS, WNPS);




  FUNCTION ParseRow(buffer      IN OUT NOCOPY VARCHAR2,
                    buffer_size IN NUMBER,
                    buffer_ptr  IN OUT NOCOPY NUMBER,
                    ncols       IN NUMBER,
                    nrows       IN NUMBER)
                  RETURN EPS_express_t;
  PRAGMA RESTRICT_REFERENCES (ParseRow, WNDS, WNPS);

  FUNCTION ParseCol(buffer      IN OUT NOCOPY VARCHAR2,
                    buffer_size IN NUMBER,
                    buffer_ptr  IN NUMBER,
                    col_val     IN OUT NOCOPY VARCHAR2)
                  RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES (ParseCol, WNDS, WNPS);
END EPS ;

 

/
