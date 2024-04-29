--------------------------------------------------------
--  DDL for Package CUG_INCIDNT_ATTR_VALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CUG_INCIDNT_ATTR_VALS_PVT" AUTHID CURRENT_USER as
/* $Header: CUGRINTS.pls 115.5 2003/06/24 17:46:46 pkesani ship $ */

TYPE sr_rec is RECORD (
     incidnt_attr_val_id	        NUMBER:=FND_API.G_MISS_NUM,
     incident_id              	        NUMBER:=FND_API.G_MISS_NUM,
     sr_question              VARCHAR2(240):=FND_API.G_MISS_CHAR,
     override_addr_valid_flag              VARCHAR2(1):=FND_API.G_MISS_CHAR,
     sr_answer              VARCHAR2(1997):=FND_API.G_MISS_CHAR,
     start_date		       DATE        :=   FND_API.G_MISS_DATE,
     end_date		        DATE        :=   FND_API.G_MISS_DATE,
	ATTRIBUTE_CATEGORY    VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE1            VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE2            VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE3            VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE4            VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE5            VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE6            VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE7            VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE8            VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE9            VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE10           VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE11           VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE12           VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE13           VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE14           VARCHAR2(150) := FND_API.G_MISS_CHAR,
	ATTRIBUTE15           VARCHAR2(150) := FND_API.G_MISS_CHAR,
  	OBJECT_VERSION_NUMBER 	NUMBER        := FND_API.G_MISS_NUM
);

TYPE sr_tbl IS TABLE OF sr_rec INDEX BY BINARY_INTEGER;

procedure CREATE_RUNTIME_DATA  (
	p_api_version     IN   NUMBER,
	p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
	p_commit       IN VARCHAR          := FND_API.G_FALSE,
	p_sr_tbl  IN 	OUT NOCOPY sr_tbl,
        x_msg_count	OUT     NOCOPY NUMBER,
        x_msg_data	OUT     NOCOPY VARCHAR2,
  	x_return_status	OUT     NOCOPY VARCHAR2 );


  PROCEDURE launch_workflow 	  (
    				   p_api_version        IN      NUMBER                                      ,
    				   p_init_msg_list      IN      VARCHAR2    := FND_API.G_FALSE              ,
    				   p_commit             IN      VARCHAR2    := FND_API.G_FALSE              ,
    				   x_return_status      OUT     NOCOPY VARCHAR2                                    ,
    				   x_msg_count          OUT     NOCOPY NUMBER                                      ,
    				   x_msg_data           OUT     NOCOPY VARCHAR2                                    ,
    				   p_incident_id        IN      NUMBER                                      ,
                       p_source             IN      VARCHAR2 DEFAULT NULL                       );





 PROCEDURE Create_Address_Note (
		p_api_version    IN   NUMBER,
		p_init_msg_list  IN   VARCHAR2  := FND_API.G_FALSE,
		p_commit	 IN 	VARCHAR   := FND_API.G_FALSE,
		p_incident_id IN Number,
		x_msg_count		OUT  NOCOPY NUMBER,
		x_msg_data		OUT  NOCOPY VARCHAR2,
  		x_return_status	OUT     NOCOPY VARCHAR2 ,
		x_note_id OUT NOCOPY NUMBER );

end CUG_INCIDNT_ATTR_VALS_PVT ;

 

/
