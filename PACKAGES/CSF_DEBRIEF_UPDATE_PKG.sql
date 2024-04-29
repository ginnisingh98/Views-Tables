--------------------------------------------------------
--  DDL for Package CSF_DEBRIEF_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_DEBRIEF_UPDATE_PKG" AUTHID CURRENT_USER as
/* $Header: csfuppds.pls 120.1 2006/01/05 13:34:34 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSF_DEBRIEF_UPDATE_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

TYPE debrief_status_rec_type IS RECORD (
  task_id                    NUMBER := null,
  task_number                VARCHAR2(30) := null,
  debrief_header_id          number := null,
  debrief_number             varchar2(50) := null,
  debrief_status             VARCHAR2(1) := null);

  g_miss_debrief_status_rec  debrief_status_rec_type;
  g_debrief_status_rec       debrief_status_rec_type;

TYPE  debrief_status_tbl_type IS TABLE OF debrief_status_rec_type
                                    INDEX BY BINARY_INTEGER;
  g_miss_debrief_status_tbl debrief_status_tbl_type;
  g_debrief_status_tbl      debrief_status_tbl_type;

  g_debrief_line_id         number := null;
  g_account_id              number := null;

PROCEDURE main
(   errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY NUMBER,
    p_api_version           IN  NUMBER,
    p_debrief_header_id     IN  NUMBER DEFAULT null,
    p_incident_id           IN  NUMBER DEFAULT null
);


PROCEDURE Form_Call
(
    p_api_version           IN  NUMBER,
    p_debrief_header_id       IN  NUMBER
);




procedure relieve_reservations(p_task_assignment_id IN NUMBER,
                               x_return_status      OUT NOCOPY varchar2,
                               x_msg_data           OUT NOCOPY varchar2,
                               x_msg_count          OUT NOCOPY varchar2
)  ;

PROCEDURE web_Call
(
    p_api_version           IN  NUMBER,
    p_task_assignment_id       IN  NUMBER
);

PROCEDURE DEBRIEF_STATUS_CHECK  (
            p_incident_id          in         number,
            p_api_version          in         number,
            p_validation_level     in         number default 0,
            x_debrief_status       out nocopy debrief_status_tbl_type,
            x_return_status        out nocopy varchar2,
            x_msg_count            out nocopy number,
            x_msg_data             out nocopy varchar2);
end;


 

/
