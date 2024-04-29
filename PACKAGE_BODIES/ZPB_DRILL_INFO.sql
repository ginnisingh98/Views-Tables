--------------------------------------------------------
--  DDL for Package Body ZPB_DRILL_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_DRILL_INFO" AS
/* $Header: zpbdrill.plb 120.1 2007/12/04 15:25:45 mbhat noship $ */

  procedure get_drill_info ( p_view        IN  VARCHAR2
                           , p_drill_info  IN  VARCHAR2
                           , x_drill_value OUT NOCOPY VARCHAR2
                           , x_result      OUT NOCOPY VARCHAR2
                           , x_msg_out     OUT NOCOPY VARCHAR2) AS
  l_bp_id          zpb_analysis_cycles.analysis_cycle_id%TYPE;
  l_ds_code        zpb_cycle_datasets.DATASET_CODE%TYPE;
  l_ledger_id      zpb_busarea_ledgers.ledger_id%TYPE;
  l_ledger_count   NUMBER := 0;
  l_dataset_count  NUMBER := 0;

  -- get the BP id
  cursor c_bp_id is select instance_id from zpb_measures where type = 'SHARED_VIEW_DATA'
    and name = p_view;

  -- get the BP id
  cursor c_ds_id is select DATASET_CODE from zpb_cycle_datasets
    where (ANALYSIS_CYCLE_ID = l_bp_id) OR
          (ANALYSIS_CYCLE_ID = (select max(ANALYSIS_CYCLE_ID)  from  zpb_analysis_cycles
                                where  CURRENT_INSTANCE_ID = l_bp_id and
                                status_code = 'COMPLETE'));

  -- get the BP id
  cursor c_ledger_id(cp_ds_id  zpb_cycle_datasets.DATASET_CODE%TYPE) is
    select distinct ledger_id from fem_data_locations where dataset_code = cp_ds_id;

  BEGIN
    x_result := 'S';

    IF (p_view is NOT NULL) THEN
      IF (p_drill_info = 'ENABLE_DRILL') THEN

        OPEN c_bp_id;
        FETCH c_bp_id into l_bp_id;
        CLOSE c_bp_id;

        IF (l_bp_id is null) THEN

          x_drill_value := 'N';
          x_msg_out := 'This view is either invalid or does not have loaded data';
          x_result := 'E';
          return;
        END IF;

        FOR i in c_ds_id LOOP
          l_dataset_count := l_dataset_count + 1;
          FOR j in c_ledger_id(i.dataset_code) LOOP
            l_ledger_count := l_ledger_count + 1;
          END LOOP;
        END LOOP;

        IF( l_dataset_count = 0 ) THEN
          x_drill_value := 'N';
          x_result := 'E';
          x_msg_out := 'This view does not have loaded data';
          return;
        END IF;

        IF( l_ledger_count = 0 ) THEN
          x_result := 'E';
          x_drill_value := 'N';
          x_msg_out := 'Dataset not mapped to a ledger!';
          return;
        ELSIF (l_ledger_count > 1) THEN
          x_result := 'S';
          x_drill_value := 'N';
          x_msg_out := 'There are multilple ledgers being loaded';
          return;
        ELSE
          x_result := 'S';
          x_drill_value := 'Y';
          x_msg_out := 'There is a single ledger loaded';
          return;
        END IF;
      ELSE
        x_msg_out := 'The drill info asked for is not valid';
        x_result := 'E';
        x_drill_value := 'N';
        return;
      END IF;

    ELSE
      x_msg_out := 'View passed in is null';
      x_drill_value := 'N';
      x_result := 'E';
      return;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_result := 'U';
      x_drill_value := 'N';
      x_msg_out := 'Unexpected error '|| sqlerrm;
  END get_drill_info ;

END zpb_drill_info ;

/
