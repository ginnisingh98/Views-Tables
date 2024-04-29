--------------------------------------------------------
--  DDL for Package PA_PAGE_CONTENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAGE_CONTENTS_PKG" AUTHID CURRENT_USER AS
--$Header: PAPGCTTS.pls 115.2 2002/12/03 18:19:42 mwasowic noship $


procedure INSERT_PAGE_CONTENTS_ROW (

  P_PAGE_CONTENT_ID     IN NUMBER,
  P_OBJECT_TYPE    	IN VARCHAR2,
  P_PK1_VALUE      	IN VARCHAR2,
  P_PK2_VALUE      	IN VARCHAR2,
  P_PK3_VALUE      	IN VARCHAR2,
  P_PK4_VALUE      	IN VARCHAR2,
  P_PK5_VALUE      	IN VARCHAR2,

  x_return_status       OUT    NOCOPY VARCHAR2,
  x_msg_count           OUT    NOCOPY NUMBER,
  x_msg_data            OUT    NOCOPY VARCHAR2
);


procedure CLEAR_CLOB (
  P_PAGE_CONTENT_ID       IN NUMBER,
  --P_RECORD_VERSION_NUMBER IN NUMBER := NULL,

  x_return_status         OUT    NOCOPY VARCHAR2,
  x_msg_count             OUT    NOCOPY NUMBER,
  x_msg_data              OUT    NOCOPY VARCHAR2
);

procedure UPDATE_PAGE_CONTENTS_ROW (
  P_PAGE_CONTENT_ID       in NUMBER,
  P_OBJECT_TYPE           in VARCHAR2,
  P_PK1_VALUE             in VARCHAR2,
  P_PK2_VALUE             in VARCHAR2,
  P_PK3_VALUE             in VARCHAR2,
  P_PK4_VALUE             in VARCHAR2,
  P_PK5_VALUE             in VARCHAR2,
  p_record_version_number IN NUMBER,

  x_return_status               OUT    NOCOPY VARCHAR2,
  x_msg_count                   OUT    NOCOPY NUMBER,
  x_msg_data                    OUT    NOCOPY VARCHAR2
);



procedure DELETE_PAGE_CONTENTS_ROW (
  P_PAGE_CONTENT_ID       in NUMBER,
  x_return_status               OUT    NOCOPY VARCHAR2,
  x_msg_count                   OUT    NOCOPY NUMBER,
  x_msg_data                    OUT    NOCOPY VARCHAR2
);
END  PA_PAGE_CONTENTS_PKG;

 

/
