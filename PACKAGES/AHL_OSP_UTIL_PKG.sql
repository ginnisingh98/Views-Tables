--------------------------------------------------------
--  DDL for Package AHL_OSP_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: AHLVOPUS.pls 120.4 2008/05/05 15:22:17 mpothuku ship $ */

-- Start of Comments --
--  Procedure name    : Log_Transaction
--  Type              : Private
--  Function          : Writes the details about a transaction in the Log Table
--  Pre-reqs    :
--  Parameters  :
--
--  Log_Transaction Parameters:
--      p_trans_type_code               IN      VARCHAR2     Required
--      p_src_doc_id                    IN      VARCHAR2     Required
--      p_src_doc_type_code             IN      VARCHAR2     Required
--      p_dest_doc_id                   IN      VARCHAR2     Required
--      p_dest_doc_type_code            IN      VARCHAR2     Required
--      p_attribute_category            IN      VARCHAR2     Default NULL
--      p_attribute1                    IN      VARCHAR2     Default NULL
--      p_attribute2                    IN      VARCHAR2     Default NULL
--      p_attribute3                    IN      VARCHAR2     Default NULL
--      p_attribute4                    IN      VARCHAR2     Default NULL
--      p_attribute5                    IN      VARCHAR2     Default NULL
--      p_attribute6                    IN      VARCHAR2     Default NULL
--      p_attribute7                    IN      VARCHAR2     Default NULL
--      p_attribute8                    IN      VARCHAR2     Default NULL
--      p_attribute9                    IN      VARCHAR2     Default NULL
--      p_attribute10                   IN      VARCHAR2     Default NULL
--      p_attribute11                   IN      VARCHAR2     Default NULL
--      p_attribute12                   IN      VARCHAR2     Default NULL
--      p_attribute13                   IN      VARCHAR2     Default NULL
--      p_attribute14                   IN      VARCHAR2     Default NULL
--      p_attribute15                   IN      VARCHAR2     Default NULL
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
PROCEDURE Log_Transaction
(
    p_trans_type_code       IN VARCHAR2,
    p_src_doc_id            IN NUMBER,
    p_src_doc_type_code     IN VARCHAR2,
    p_dest_doc_id           IN NUMBER,
    p_dest_doc_type_code    IN VARCHAR2,
    p_attribute_category    IN VARCHAR2 := null,
    p_attribute1            IN VARCHAR2 := null,
    p_attribute2            IN VARCHAR2 := null,
    p_attribute3            IN VARCHAR2 := null,
    p_attribute4            IN VARCHAR2 := null,
    p_attribute5            IN VARCHAR2 := null,
    p_attribute6            IN VARCHAR2 := null,
    p_attribute7            IN VARCHAR2 := null,
    p_attribute8            IN VARCHAR2 := null,
    p_attribute9            IN VARCHAR2 := null,
    p_attribute10           IN VARCHAR2 := null,
    p_attribute11           IN VARCHAR2 := null,
    p_attribute12           IN VARCHAR2 := null,
    p_attribute13           IN VARCHAR2 := null,
    p_attribute14           IN VARCHAR2 := null,
    p_attribute15           IN VARCHAR2 := null
);

/******** The following are used to facilitate dynamic binding *********/
-- The REF CURSOR type to be used for all large dynamic binding queries
TYPE ahl_search_csr is REF CURSOR;

-- The array to be used to pass binding values
TYPE ahl_conditions_tbl IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

-- Start of Comments --
--  Procedure name    : OPEN_SEARCH_CURSOR
--  Type              : Public
--  Function          : Opens a ref cursor that may have zero to a maximum of 16
--                      dynamic binding variables
--  Pre-reqs    :
--  Parameters  :
--
--  OPEN_SEARCH_CURSOR Parameters:
--      p_x_csr               IN OUT  ahl_search_csr     Required
--                            This is the cursor to be opened
--      p_conditions_tbl      IN      ahl_conditions_tbl     Required
--                            This is the array containing the binding values
--      p_sql_str             IN      VARCHAR2     Required
--                            This is the sql string with the bind parameters
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
PROCEDURE OPEN_SEARCH_CURSOR(p_x_csr          IN OUT NOCOPY ahl_search_csr,
                             p_conditions_tbl IN            ahl_conditions_tbl,
                             p_sql_str        IN            VARCHAR2);

-- Start of Comments --
--  Procedure name    : EXEC_IMMEDIATE
--  Type              : Public
--  Function          : Does an execute immediate of a SQL statement that returns
--                      a single number value and that has up to 16 bind variables (0 to 16)
--  Pre-reqs    :
--  Parameters  :
--
--  EXEC_IMMEDIATE Parameters:
--      p_conditions_tbl      IN      ahl_conditions_tbl     Required
--                            This is the array containing the binding values
--      p_sql_str             IN      VARCHAR2     Required
--                            This is the sql string with the bind parameters
--      x_results_count       OUT      NUMBER     Required
--                            This is the result of the execute immediate operation
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
PROCEDURE EXEC_IMMEDIATE(p_conditions_tbl IN         ahl_conditions_tbl,
                         p_sql_str        IN         VARCHAR2,
                         x_results_count  OUT NOCOPY NUMBER);


/* Following two functions added by jaramana on March 14, 2006 for fixing Perf Bug 4914529 */
/* These two functions are used in ShipmentLinesVO.xml to get the Instance number and *
/* the Serial number respectively of a Shipment Line */

FUNCTION GET_SHIP_LINE_INSTANCE_NUMBER(p_ship_line_id IN NUMBER,
                                       p_osp_line_id  IN NUMBER) RETURN VARCHAR2;

FUNCTION GET_SHIP_LINE_SERIAL_NUMBER(p_ship_line_id IN NUMBER,
                                     p_osp_line_id  IN NUMBER) RETURN VARCHAR2;

--Added by mpothuku on 09-Jan-2008 to implement the Osp Receiving feature
FUNCTION GET_SHIP_LINE_INSTANCE_ID(p_ship_line_id IN NUMBER,
                                   p_osp_line_id  IN NUMBER) RETURN NUMBER;

--Added by mpothuku on 05-May-2008 to fix the Bug 6322216
FUNCTION GET_SHIP_LINE_LOT_NUMBER(p_ship_line_id IN NUMBER,
                                  p_osp_line_id  IN NUMBER) RETURN VARCHAR2;


End AHL_OSP_UTIL_PKG;

/
