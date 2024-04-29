--------------------------------------------------------
--  DDL for Package FA_MAINTENANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MAINTENANCE_PKG" AUTHID CURRENT_USER as
/* $Header: FAXMTSCS.pls 120.2.12010000.2 2009/07/19 11:09:02 glchen ship $ */


TYPE event_rec_type is RECORD
(
       SCHEDULE_ID                     NUMBER(15),
       EVENT_NAME                      VARCHAR2(50),
       DESCRIPTION                     VARCHAR2(80),
       FREQUENCY_IN_DAYS               NUMBER(15),
       MAINTENANCE_DATE                DATE,
       COST                            NUMBER,
       EMPLOYEE_ID                     NUMBER(15),
       VENDOR_ID                       NUMBER(15),
       created_by			number(15),
       creation_date		        date,
       last_updated_by		       number(15),
       last_update_login		number(15),
       last_update_date		       date,
       attribute1		       varchar2(150),
       attribute2                      varchar2(150),
       attribute3                      varchar2(150),
       attribute4                      varchar2(150),
       attribute5                      varchar2(150),
       attribute6                      varchar2(150),
       attribute7                      varchar2(150),
       attribute8                      varchar2(150),
       attribute9                      varchar2(150),
       attribute10                     varchar2(150),
       attribute11                     varchar2(150),
       attribute12                     varchar2(150),
       attribute13                     varchar2(150),
       attribute14                     varchar2(150),
       attribute15                     varchar2(150),
       attribute_category              varchar2(30)
);


TYPE events_tbl_type is TABLE OF event_rec_type
INDEX BY BINARY_INTEGER;


procedure do_schedule(
		errbuf    	  out nocopy varchar2,
		retcode		  out nocopy varchar2,
		argument1 	  in  varchar2,   -- schedule_id
	  	argument2         in  varchar2  default  null,
		argument3         in  varchar2  default  null,
	  	argument4         in  varchar2  default  null,
	  	argument5         in  varchar2  default  null,
	  	argument6         in  varchar2  default  null,
	  	argument7         in  varchar2  default  null,
	  	argument8         in  varchar2  default  null,
	  	argument9         in  varchar2  default  null,
	  	argument10        in  varchar2  default  null,
	  	argument11        in  varchar2  default  null,
	  	argument12        in  varchar2  default  null,
	  	argument13        in  varchar2  default  null,
		argument14        in  varchar2  default  null,
		argument15        in  varchar2  default  null,
		argument16        in  varchar2  default  null,
		argument17        in  varchar2  default  null,
		argument18        in  varchar2  default  null,
		argument19        in  varchar2  default  null,
		argument20        in  varchar2  default  null,
		argument21        in  varchar2  default  null,
		argument22        in  varchar2  default  null,
		argument23        in  varchar2  default  null,
		argument24        in  varchar2  default  null,
		argument25        in  varchar2  default  null,
		argument26        in  varchar2  default  null,
		argument27        in  varchar2  default  null,
		argument28        in  varchar2  default  null,
		argument29        in  varchar2  default  null,
		argument30        in  varchar2  default  null,
		argument31        in  varchar2  default  null,
		argument32        in  varchar2  default  null,
		argument33        in  varchar2  default  null,
		argument34        in  varchar2  default  null,
		argument35        in  varchar2  default  null,
		argument36        in  varchar2  default  null,
		argument37        in  varchar2  default  null,
		argument38        in  varchar2  default  null,
		argument39        in  varchar2  default  null,
		argument40        in  varchar2  default  null,
		argument41        in  varchar2  default  null,
		argument42        in  varchar2  default  null,
		argument43        in  varchar2  default  null,
		argument44        in  varchar2  default  null,
		argument45        in  varchar2  default  null,
		argument46        in  varchar2  default  null,
		argument47        in  varchar2  default  null,
		argument48        in  varchar2  default  null,
		argument49        in  varchar2  default  null,
		argument50        in  varchar2  default  null,
		argument51        in  varchar2  default  null,
		argument52        in  varchar2  default  null,
		argument53        in  varchar2  default  null,
		argument54        in  varchar2  default  null,
		argument55        in  varchar2  default  null,
		argument56        in  varchar2  default  null,
		argument57        in  varchar2  default  null,
		argument58        in  varchar2  default  null,
		argument59        in  varchar2  default  null,
		argument60        in  varchar2  default  null,
		argument61        in  varchar2  default  null,
		argument62        in  varchar2  default  null,
		argument63        in  varchar2  default  null,
		argument64        in  varchar2  default  null,
		argument65        in  varchar2  default  null,
		argument66        in  varchar2  default  null,
		argument67        in  varchar2  default  null,
		argument68        in  varchar2  default  null,
		argument69        in  varchar2  default  null,
		argument70        in  varchar2  default  null,
		argument71        in  varchar2  default  null,
		argument72        in  varchar2  default  null,
		argument73        in  varchar2  default  null,
		argument74        in  varchar2  default  null,
		argument75        in  varchar2  default  null,
		argument76        in  varchar2  default  null,
		argument77        in  varchar2  default  null,
		argument78        in  varchar2  default  null,
		argument79        in  varchar2  default  null,
		argument80        in  varchar2  default  null,
		argument81        in  varchar2  default  null,
		argument82        in  varchar2  default  null,
		argument83        in  varchar2  default  null,
		argument84        in  varchar2  default  null,
		argument85        in  varchar2  default  null,
		argument86        in  varchar2  default  null,
		argument87        in  varchar2  default  null,
		argument88        in  varchar2  default  null,
		argument89        in  varchar2  default  null,
		argument90        in  varchar2  default  null,
		argument91        in  varchar2  default  null,
		argument92        in  varchar2  default  null,
		argument93        in  varchar2  default  null,
		argument94        in  varchar2  default  null,
		argument95        in  varchar2  default  null,
		argument96        in  varchar2  default  null,
		argument97        in  varchar2  default  null,
		argument98        in  varchar2  default  null,
		argument99        in  varchar2  default  null,
		argument100       in  varchar2  default  null);

procedure upd_status(
             p_sch_id      in number,
             p_msg_name    in varchar2);

procedure insert_to_fa_maint_events(
             p_asset_id       in number,
             p_book_type_code in varchar2,
             p_event_rec      in event_rec_type,
             p_maint_date     in date,
             p_succeed        out nocopy boolean);

procedure load_events_records(
             p_schedule_id  in     number,
             p_events_tbl   in out nocopy events_tbl_type,
             p_succeed      out nocopy  boolean);

END FA_MAINTENANCE_PKG;

/
