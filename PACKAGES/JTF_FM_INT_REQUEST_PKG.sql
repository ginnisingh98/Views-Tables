--------------------------------------------------------
--  DDL for Package JTF_FM_INT_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_INT_REQUEST_PKG" AUTHID CURRENT_USER AS
/* $Header: jtffmrqs.pls 120.6 2006/03/15 11:34:44 jakaur noship $*/

PROCEDURE  process_request( request_id                 NUMBER
                          , x_return_status OUT NOCOPY VARCHAR2
                          , x_msg_count     OUT NOCOPY NUMBER
                          , x_msg_data      OUT NOCOPY VARCHAR2
                          );

PROCEDURE update_lines_status_bulk( line_ids        IN         JTF_VARCHAR2_TABLE_100
                                  , request_id      IN         NUMBER
                                  , line_status     IN         JTF_VARCHAR2_TABLE_100
                                  , p_commit        IN         VARCHAR2   := Fnd_Api.G_FALSE
                                  , x_return_status OUT NOCOPY VARCHAR2
                                  , x_msg_count     OUT NOCOPY NUMBER
                                  , x_msg_data      OUT NOCOPY VARCHAR2
                                  ) ;

PROCEDURE update_lines_status( line_ids        IN         JTF_VARCHAR2_TABLE_100
                             , request_id      IN         NUMBER
                             , line_status     IN         VARCHAR2
                             , p_commit        IN         VARCHAR2   := Fnd_Api.G_FALSE
                             , x_return_status OUT NOCOPY VARCHAR2
                             , x_msg_count     OUT NOCOPY NUMBER
                             , x_msg_data      OUT NOCOPY VARCHAR2
                             ) ;

PROCEDURE clean_up_instance( p_request_id    IN         NUMBER
                           , p_server_id     IN         NUMBER
                           , p_instance_id   IN         NUMBER
                           , p_commit        IN         VARCHAR2   := Fnd_Api.G_FALSE
                           , x_return_status OUT NOCOPY VARCHAR2
                           , x_msg_count     OUT NOCOPY NUMBER
                           , x_msg_data      OUT NOCOPY VARCHAR2
                           ) ;

TYPE request_lines_rec IS TABLE OF JTF_FM_INT_REQUEST_LINES%ROWTYPE
     INDEX BY PLS_INTEGER;

PROCEDURE get_next_request( p_server_id              IN         NUMBER
                          , p_instance_id            IN         NUMBER
                          , p_REQUEST_ID             OUT NOCOPY NUMBER
                          , p_template_id            OUT NOCOPY NUMBER
                          , p_NO_OF_PARAMETERS       OUT NOCOPY NUMBER
                          , p_EMAIL_FORMAT           OUT NOCOPY VARCHAR2
                          , p_EMAIL_FROM_ADDRESS     OUT NOCOPY VARCHAR2
                          , p_EMAIL_REPLY_TO_ADDRESS OUT NOCOPY VARCHAR2
                          , p_sender_display_name    OUT NOCOPY VARCHAR2
                          , p_subject                OUT NOCOPY VARCHAR2
                          , p_parameter_table        OUT NOCOPY JTF_VARCHAR2_TABLE_100
                          , x_return_status          OUT NOCOPY VARCHAR2
                          , x_msg_count              OUT NOCOPY NUMBER
                          , x_msg_data               OUT NOCOPY VARCHAR2
                          ) ;

PROCEDURE update_instance_status( p_REQUEST_ID    IN         NUMBER
                                , p_server_id     IN         NUMBER
                                , p_instance_id   IN         NUMBER
                                , p_status        IN         VARCHAR2
                                , P_COMMIT        IN         VARCHAR2   := Fnd_Api.G_FALSE
                                , x_return_status OUT NOCOPY VARCHAR2
                                , x_msg_count     OUT NOCOPY NUMBER
                                , x_msg_data      OUT NOCOPY VARCHAR2
                                ) ;

PROCEDURE  get_next_batch ( p_REQUEST_ID           IN         NUMBER
                          , p_server_id            IN         NUMBER
                          , p_instance_id          IN         NUMBER
                          , P_COMMIT               IN         VARCHAR2   := Fnd_Api.G_FALSE
                          , p_line_ids             OUT NOCOPY JTF_NUMBER_TABLE
                          , p_PARTY_ID             OUT NOCOPY JTF_NUMBER_TABLE
                          , p_PARTY_NAME           OUT NOCOPY JTF_VARCHAR2_TABLE_200
                          , p_EMAIL_ADDRESS        OUT NOCOPY JTF_VARCHAR2_TABLE_200
                          , p_COL1                 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL2                 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL3                 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL4                 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL5                 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL6                 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL7                 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL8                 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL9                 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL10                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL11                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL12                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL13                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL14                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL15                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL16                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL17                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL18                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL19                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL20                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL21                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL22                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL23                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL24                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL25                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL26                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL27                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL28                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL29                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL30                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL31                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL32                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL33                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL34                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL35                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL36                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL37                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL38                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL39                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL40                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL41                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL42                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL43                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL44                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL45                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL46                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL47                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL48                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL49                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL50                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL51                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL52                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL53                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL54                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL55                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL56                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL57                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL58                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL59                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL60                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL61                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL62                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL63                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL64                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL65                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL66                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL67                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL68                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL69                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL70                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL71                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL72                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL73                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL74                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL75                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL76                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL77                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL78                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL79                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL80                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL81                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL82                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL83                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL84                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL85                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL86                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL87                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL88                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL89                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL90                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL91                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL92                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL93                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL94                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL95                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL96                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL97                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL98                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL99                OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , p_COL100               OUT NOCOPY JTF_VARCHAR2_TABLE_2000
                          , x_no_of_rows           OUT NOCOPY  NUMBER
                          , x_return_status        OUT NOCOPY VARCHAR2
                          , x_msg_count            OUT NOCOPY NUMBER
                          , x_msg_data             OUT NOCOPY VARCHAR2) ;


PROCEDURE  move_request( p_request_id                    NUMBER
                       , x_log_interaction    OUT NOCOPY VARCHAR2
                       , x_return_status      OUT NOCOPY VARCHAR2
                       , x_msg_count          OUT NOCOPY NUMBER
                       , x_msg_data           OUT NOCOPY VARCHAR2
                       ) ;
END Jtf_Fm_Int_Request_Pkg ;

 

/
