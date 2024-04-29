--------------------------------------------------------
--  DDL for Package EBS_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EBS_DRT_PKG" AUTHID CURRENT_USER as
/* $Header: ebdrtpkg.pkh 120.0.12010000.4 2018/04/19 15:40:45 ktithy noship $ */

/*  TYPE process_record_type IS RECORD (person_id    number(15)
                                     ,entity_type  varchar2(3)
                                     ,status       varchar2(1)
                                     ,msgcode      varchar2(30)
                                     ,msgaplid     number(15));

  TYPE result_tbl_type IS TABLE OF process_record_type INDEX BY binary_integer;
*/

  TYPE dependency_record_type IS RECORD (person_id    varchar2(15)
                                        ,person_type  varchar2(3));

  TYPE dependency_tbl_type IS TABLE OF dependency_record_type INDEX BY binary_integer;

  g_dependency_tbl dependency_tbl_type;
  g_removal_tbl EBS_DRT_REMOVAL_REC;


  PROCEDURE write_log
    (message       IN         varchar2
    ,stage     IN         varchar2);

  PROCEDURE add_to_results
    (person_id       IN         number
    ,entity_type     IN         varchar2
    ,status          IN         varchar2
    ,msgcode         IN         varchar2
    ,msgaplid        IN         number
    ,result_tbl      IN OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE ebs_hr_pre
    (person_id       IN         number);

  PROCEDURE ebs_tca_pre
    (person_id       IN         number);

  PROCEDURE ebs_fnd_pre
    (person_id       IN         number);

  PROCEDURE ebs_drt_pre
    (person_id       IN         number
    ,entity_type     IN         varchar2);

  PROCEDURE ebs_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE ebs_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE ebs_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE ebs_drt_drc
    (person_id       IN         number
    ,entity_type     IN         varchar2
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE ebs_hr_post
    (person_id       IN         number);

  PROCEDURE ebs_tca_post
    (person_id       IN         number);

  PROCEDURE ebs_fnd_post
    (person_id       IN         number);

  PROCEDURE ebs_drt_post
    (person_id       IN         number
		,entity_type     IN         varchar2);

  PROCEDURE drt_dependency_checker
    (person_id      IN         varchar2
    ,person_type    IN         varchar2
    ,dependency_tbl OUT NOCOPY dependency_tbl_type);

  PROCEDURE drc_results
    (person_id       IN         number
    ,entity_type     IN         varchar2
    ,error    OUT NOCOPY number
    ,warning  OUT NOCOPY number
    ,results_tbl OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE check_drc
    (chk_drc_batch IN  EBS_DRT_REMOVAL_REC
    ,request_id OUT NOCOPY number);

  procedure submit_request(errbuf           out NOCOPY varchar2,
                          retcode           out NOCOPY number,
                          p_batch_id number) ;

  PROCEDURE drt_remove
    (removal_batch IN  EBS_DRT_REMOVAL_REC
    ,request_id OUT NOCOPY number);

procedure submit_remove_request(errbuf out NOCOPY varchar2,
                                retcode out NOCOPY number,
                                p_batch_id number) ;


end ebs_drt_pkg;

/
