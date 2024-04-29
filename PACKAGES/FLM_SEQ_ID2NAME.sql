--------------------------------------------------------
--  DDL for Package FLM_SEQ_ID2NAME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_SEQ_ID2NAME" AUTHID CURRENT_USER AS
/* $Header: FLMSQIDS.pls 120.0.12000000.1 2007/01/19 09:30:58 appldev ship $  */

TYPE ID2Name_t IS RECORD (
    table_name       VARCHAR2(40),
    column_name      VARCHAR2(40),
    query_string     VARCHAR2(2000)
  );

TYPE ID2Name_TABLE_t IS TABLE OF ID2Name_t INDEX BY BINARY_INTEGER;

ID2Name_Table ID2Name_TABLE_t;


/******************************************************************
 * Initialize ID2Name_Table if it is not initialized.             *
 ******************************************************************/
PROCEDURE ID2NameInit;

/******************************************************************
 * To check whether given attribute needs ID2Name translation     *
 ******************************************************************/
PROCEDURE ID2Name(     p_attribute_id IN NUMBER,
                       p_init_msg_list IN VARCHAR2,
                       x_id2name OUT NOCOPY VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2
                 );

/*****************************************************
 * To return a LOV query for given ID column.        *
 *****************************************************/
PROCEDURE ID2NameLovQuery(    p_attribute_id IN NUMBER,
                              p_init_msg_list IN VARCHAR2,
                              x_query OUT NOCOPY VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2);

/******************************************************************
 * To check whether given table.column needs ID2Name translation  *
 ******************************************************************/
PROCEDURE ID2Name(     p_table IN VARCHAR2,
                       p_column IN VARCHAR2,
                       p_init_msg_list IN VARCHAR2,
		       x_id2name OUT NOCOPY VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2
                 );

/*****************************************************
 * To return a LOV query for given ID column.        *
 *****************************************************/
PROCEDURE ID2NameLovQuery(    p_table IN VARCHAR2,
                              p_column IN VARCHAR2,
                              p_init_msg_list IN VARCHAR2,
                              x_query OUT NOCOPY VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2);


/*****************************************************
 * To return a name for given ID column and ID value *
 *****************************************************/
PROCEDURE ID2NameAttributeValue(
                              p_table IN VARCHAR2,
                              p_column IN VARCHAR2,
                              p_org_id IN NUMBER,
                              p_value IN NUMBER,
                              p_init_msg_list IN VARCHAR2,
                              x_name OUT NOCOPY VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2);


END flm_seq_id2name;

 

/
