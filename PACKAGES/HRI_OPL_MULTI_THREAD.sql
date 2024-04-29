--------------------------------------------------------
--  DDL for Package HRI_OPL_MULTI_THREAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_MULTI_THREAD" AUTHID CURRENT_USER AS
/* $Header: hriomthd.pkh 120.6 2006/11/24 15:59:10 jtitmas noship $ */
--
other_thread_in_error EXCEPTION;
child_process_failure EXCEPTION;
INVALID_SQL           EXCEPTION;
--
g_mthd_action_array hri_adm_mthd_actions%rowtype;
--
-- This is the entry for the master thread or the Multithread Utility
-- It controls the master threads and its processing
--
PROCEDURE process  (errbuf                             OUT NOCOPY  VARCHAR2,
                    retcode                            OUT NOCOPY  NUMBER,
                    p_program                       IN             VARCHAR2,
                    p_business_group_id             IN             NUMBER,
                    p_collect_from_date             IN             VARCHAR2,
                    p_collect_to_date               IN             VARCHAR2,
                    p_full_refresh_flag             IN             VARCHAR2,
                    p_hierarchical_process          IN             VARCHAR2 DEFAULT 'N',
                    p_hierarchical_type             IN             VARCHAR2 DEFAULT NULL,
                    p_attribute1                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute2                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute3                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute4                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute5                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute6                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute7                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute8                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute9                    IN             VARCHAR2 DEFAULT NULL,
                    p_attribute10                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute11                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute12                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute13                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute14                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute15                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute16                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute17                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute18                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute19                   IN             VARCHAR2 DEFAULT NULL,
                    p_attribute20                   IN             VARCHAR2 DEFAULT NULL)   ;
--
-- Obsolete function to get next range id
--
FUNCTION get_next_mthd_range_id
                 (p_rownum number
                 ,p_chunk  number
                 )
RETURN NUMBER;
--
-- This procedure serves the request raised by the child threading for
-- allocation of a range for processing. This procedure serves as the
-- controller for ranges
--
PROCEDURE get_next_range(p_mthd_action_id          IN            NUMBER
                        ,p_mthd_range_id           IN OUT NOCOPY NUMBER
                        ,p_mthd_range_lvl             OUT NOCOPY NUMBER
                        ,p_mthd_range_lvl_order       OUT NOCOPY NUMBER
                        ,p_start_object_id            OUT NOCOPY NUMBER
                        ,p_end_object_id              OUT NOCOPY NUMBER
                        ,p_mode                    IN            VARCHAR2 default 'N') ;
--
-- This procedure generates the range_id
--
PROCEDURE gen_object_range (p_mthd_action_id  NUMBER);
--
-- Entry point for starting the child threads. It is directly invoked from the
-- concurrent manager
--
PROCEDURE process_range(
                        errbuf                        OUT NOCOPY VARCHAR2
                        ,retcode                      OUT NOCOPY NUMBER
                        ,p_master_request_id      IN             NUMBER
                        ,p_program                IN             VARCHAR2
                        ,p_mthd_action_id         IN             NUMBER
                        ,p_worker_id              IN             NUMBER);
--
PROCEDURE output(p_text  VARCHAR2);
--
PROCEDURE dbg(p_text  VARCHAR2);
--
-- This procedure returns the multithreading action record.
--
FUNCTION get_mthd_action_array(p_mthd_action_id  IN NUMBER)
RETURN hri_adm_mthd_actions%rowtype;
--
-- This procedure fetches a new mthd_action_id of the invoking
-- process.
--
FUNCTION get_mthd_action_id(p_program            IN    VARCHAR2,
			    p_start_time         IN    DATE)
RETURN NUMBER;
--
PROCEDURE update_parameters(p_mthd_action_id     IN NUMBER,
                            p_full_refresh       IN VARCHAR2,
                            p_global_start_date  IN DATE);
--
FUNCTION get_worker_id RETURN NUMBER;
--
PROCEDURE wait_for_lower_levels(p_mthd_action_id        IN NUMBER
                               ,p_mthd_range_lvl_order  IN NUMBER);
--
END hri_opl_multi_thread;

/
