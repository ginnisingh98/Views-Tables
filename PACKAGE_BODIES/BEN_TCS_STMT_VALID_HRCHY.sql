--------------------------------------------------------
--  DDL for Package Body BEN_TCS_STMT_VALID_HRCHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_TCS_STMT_VALID_HRCHY" as
/* $Header: bentcshg.pkb 120.1 2006/04/12 04:45 srangasa noship $ */
item_hrchy_values cat_item_hrchy_table ;
subcat_hrchy_values cat_subcat_hrchy_table ;

--
-- ============================================================================
--                            <<write>>
-- ============================================================================
--
   PROCEDURE WRITE (p_string IN VARCHAR2)
   IS
   BEGIN
      ben_batch_utils.WRITE (p_string);
   END WRITE;



    PROCEDURE obj_hrchy_gen(p_stmt_id IN NUMBER, p_bg_id IN NUMBER ,
    p_period_id IN NUMBER ,
     p_item_hrchy_values IN OUT NOCOPY cat_item_hrchy_table ,p_subcat_hrchy_values IN OUT  NOCOPY cat_subcat_hrchy_table )
     IS
      l_proc             VARCHAR2 (100)
                              := 'ben_tcs_stmt_valid_hrchy.obj_hrchy_gen';

      CURSOR c_stmt_sect (v_stmt_id IN NUMBER, v_bg_id IN NUMBER)
      IS
         SELECT cat_id
           FROM ben_tcs_stmt_cat stmt_cat
          WHERE stmt_cat.stmt_id = v_stmt_id
            AND stmt_cat.business_group_id = v_bg_id;

      CURSOR c_cat_subcat (v_cat_id IN NUMBER)
      IS
         SELECT subcat_id
           FROM ben_tcs_all_objects_in_cat stmt_all_obj
          WHERE stmt_all_obj.cat_id = v_cat_id AND subcat_id IS NOT NULL;

      CURSOR c_cat_item (v_cat_id IN NUMBER)
      IS
         SELECT stmt_all_obj.item_id, col_cat.contributor_type_cd cntr_cd ,stmt_all_obj.all_objects_in_cat_id obj_id,
           stmt_all_obj.row_in_cat_id row_id
           FROM ben_tcs_all_objects_in_cat stmt_all_obj,  ben_tcs_col_in_cat col_cat
          WHERE stmt_all_obj.cat_id = v_cat_id AND item_id IS NOT NULL
          AND col_cat.col_in_cat_id = stmt_all_obj.col_in_cat_id;

      CURSOR c_cat_parent (v_cat_id IN NUMBER)
      IS
         SELECT cat_id , row_in_cat_id ,all_objects_in_cat_id
           FROM ben_tcs_all_objects_in_cat stmt_all_obj
          WHERE stmt_all_obj.subcat_id = v_cat_id;

      CURSOR c_cat_hrchy (v_cat_id IN NUMBER, v_stmt_id NUMBER , v_period_id NUMBER)
      IS
         SELECT sub_cat_id, lvl_num
           FROM ben_tcs_cat_subcat_hrchy cat_subcat_hr
          WHERE cat_subcat_hr.cat_id = v_cat_id
            AND cat_subcat_hr.stmt_id = v_stmt_id
            ANd cat_subcat_hr.stmt_perd_id  = v_period_id ;

      CURSOR c_item_hrchy (v_cat_id IN NUMBER, v_stmt_id NUMBER, v_period_id NUMBER)
      IS
         SELECT item_id, lvl_num,cntr_cd,row_in_cat_id ,all_objects_in_cat_id
           FROM ben_tcs_cat_item_hrchy cat_item_hr
          WHERE cat_item_hr.cat_id = v_cat_id
            AND cat_item_hr.stmt_id = v_stmt_id
            AND cat_item_hr.stmt_perd_id  = v_period_id ;

      stmt_sect_rec      c_stmt_sect%ROWTYPE;
      cat_subcat_rec     c_cat_subcat%ROWTYPE;
      cat_item_rec       c_cat_item%ROWTYPE;
      cat_parent_rec     c_cat_parent%ROWTYPE;
      cat_hrchy_rec      c_cat_hrchy%ROWTYPE;
      item_hrchy_rec     c_item_hrchy%ROWTYPE;

      TYPE stmt_obj_hrchy_table IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;

      stmt_obj_hrchy     stmt_obj_hrchy_table;
      l_number_of_rows   NUMBER;
      l_number_of_rows_temp   NUMBER;
      l_check_count      NUMBER;
      temp_count         NUMBER;
      l_next_row         NUMBER;
      l_counter          NUMBER;
      l_cur_cat_id       NUMBER;
      l_id               NUMBER;
      l_count            NUMBER;
      l_cur_row          NUMBER;
      l_flag             VARCHAR2 (1);
      Enter              VARCHAR2 (1);
      l_item_cnt         NUMBER := 0;
      distinct_item      NUMBER :=0;
      item_count         NUMBER := 0;
      subcat_count       NUMBER := 0;
      item_table  item_hrchy_table;
      cat_type           VARCHAR2 (20);


   BEGIN
      WRITE ( 'Generating Hierarchy tables entries . In obj_hrchy_gen ..' );
      hr_utility.set_location ('Entering:' || l_proc, 25);
      l_count := 0;
      l_counter := 1;
      item_hrchy_values := p_item_hrchy_values ;
      subcat_hrchy_values := p_subcat_hrchy_values ;
      WRITE( ' item_id count ' || item_hrchy_values.COUNT);
      WRITE( ' subcat count ' || subcat_hrchy_values.COUNT);

      SAVEPOINT hrchy;

      OPEN c_stmt_sect (p_stmt_id, p_bg_id);
      LOOP
         FETCH c_stmt_sect
          INTO l_id;
         EXIT WHEN c_stmt_sect%NOTFOUND;
           l_count := l_count + 1;
           stmt_obj_hrchy (l_count) := l_id;
      END LOOP;
      CLOSE c_stmt_sect;
      IF NVL (stmt_obj_hrchy.LAST, 0) = 0
      THEN
         WRITE('No Section Found ....' );
         fnd_message.raise_error;
      END IF;
      l_number_of_rows := stmt_obj_hrchy.COUNT;

      WHILE (l_counter <= l_number_of_rows)
      LOOP
         l_cur_cat_id := stmt_obj_hrchy (l_counter);
         DELETE FROM ben_tcs_cat_item_hrchy
         WHERE cat_id = stmt_obj_hrchy (l_counter)
         and stmt_id  = p_stmt_id
         and stmt_perd_id = p_period_id;
         DELETE FROM ben_tcs_cat_subcat_hrchy
         WHERE cat_id = stmt_obj_hrchy (l_counter)
         and stmt_id  = p_stmt_id
         and stmt_perd_id = p_period_id;
         OPEN c_cat_subcat (l_cur_cat_id);

         LOOP
            FETCH c_cat_subcat
             INTO l_id;

            l_flag := 'N';
            EXIT WHEN c_cat_subcat%NOTFOUND;
            l_check_count := stmt_obj_hrchy.COUNT;

            FOR table_row IN 1 .. l_check_count
            LOOP
               IF (l_id = stmt_obj_hrchy (table_row))
               THEN
                  stmt_obj_hrchy (table_row) := -1;
               EXIT;
               END IF;
            END LOOP;
               l_count := l_count + 1;
               stmt_obj_hrchy (l_count) := l_id;
          END LOOP;

         CLOSE c_cat_subcat;

         l_number_of_rows := stmt_obj_hrchy.COUNT;
         l_counter := l_counter + 1;

         OPEN c_cat_item (l_cur_cat_id);
         LOOP
            FETCH c_cat_item
             INTO cat_item_rec;

            EXIT WHEN c_cat_item%NOTFOUND;

            IF c_cat_item%FOUND
            THEN
               item_count := item_hrchy_values.COUNT ;
               item_hrchy_values(item_count +1 ).stmt_id:= p_stmt_id;
               item_hrchy_values(item_count +1 ).cat_id:=l_cur_cat_id;
               item_hrchy_values(item_count +1 ).item_id:=cat_item_rec.item_id;
               item_hrchy_values(item_count +1 ).lvl_num:=1;
               item_hrchy_values(item_count +1 ).cntr_cd := cat_item_rec.cntr_cd ;
               item_hrchy_values(item_count +1 ).row_cat_id :=cat_item_rec.row_id;
               item_hrchy_values(item_count +1 ).all_objects_id := cat_item_rec.obj_id;
               item_hrchy_values(item_count +1 ).perd_id:= p_period_id;

               INSERT INTO ben_tcs_cat_item_hrchy
                           (stmt_id, cat_id, item_id, lvl_num,cntr_cd ,row_in_cat_id , all_objects_in_cat_id,stmt_perd_id
                           )
                    VALUES (p_stmt_id, l_cur_cat_id, cat_item_rec.item_id, 1,cat_item_rec.cntr_cd,
                    cat_item_rec.row_id ,cat_item_rec.obj_id , p_period_id);
               distinct_item := 0;
               for i in 1..item_table.count
               loop
                    if (item_table(i).item_id = cat_item_rec.item_id ) then
                            distinct_item := i ;
                    exit;
                    end if;
               end loop;
               if ( distinct_item = 0 ) then
               l_item_cnt := l_item_cnt +1;
               item_table(l_item_cnt).item_id := cat_item_rec.item_id;
               item_table(l_item_cnt).stmt_id := p_stmt_id;
               item_table(l_item_cnt).cntr_cd := cat_item_rec.cntr_cd;
               end if;
           END IF;
         END LOOP;
         CLOSE c_cat_item;
        -- Update ben_tcs_row_in_cat set stmt_generated = 'Y' where cat_id = l_cur_cat_id;
       END LOOP;

      l_number_of_rows := stmt_obj_hrchy.COUNT;
      l_number_of_rows_temp := stmt_obj_hrchy.COUNT;
      l_cur_row := stmt_obj_hrchy.COUNT;
      FOR table_row IN 1 .. l_number_of_rows
      LOOP
         If (stmt_obj_hrchy (l_cur_row) <> -1 ) then
          l_cur_cat_id := stmt_obj_hrchy (l_cur_row);
         OPEN c_cat_parent (l_cur_cat_id);

         LOOP
            FETCH c_cat_parent
             INTO cat_parent_rec;

            EXIT WHEN c_cat_parent%NOTFOUND;
            Enter := 'N';
            IF c_cat_parent%FOUND
            THEN
            FOR temp_count IN 1 .. l_number_of_rows_temp
            LOOP
                 IF cat_parent_rec.cat_id = stmt_obj_hrchy (temp_count) THEN
                 Enter := 'Y';
                 END IF;
            END LOOP;
            IF ENTER = 'Y' THEN

               subcat_count := subcat_hrchy_values.COUNT ;
               subcat_hrchy_values(subcat_count +1 ).stmt_id:= p_stmt_id;
               subcat_hrchy_values(subcat_count +1 ).cat_id:=cat_parent_rec.cat_id;
               subcat_hrchy_values(subcat_count +1 ).subcat_id:=l_cur_cat_id;
               subcat_hrchy_values(subcat_count +1 ).lvl_num:=1;
               subcat_hrchy_values(subcat_count +1 ).row_cat_id:=cat_parent_rec.row_in_cat_id;
               subcat_hrchy_values(subcat_count +1 ).perd_id:= p_period_id;
              INSERT INTO ben_tcs_cat_subcat_hrchy
                           (stmt_id, cat_id, sub_cat_id, lvl_num,row_in_cat_id,stmt_perd_id
                           )
                    VALUES (p_stmt_id, cat_parent_rec.cat_id, l_cur_cat_id, 1 ,cat_parent_rec.row_in_cat_id , p_period_id);

             --Added For Stk Ext
               distinct_item := 0;
               SELECT cat_type_cd
                 INTO cat_type
                 FROM BEN_TCS_CAT
                 WHERE cat_id  = l_cur_cat_id ;
               IF ( cat_type  = 'STKOPTEXT' ) THEN
               for i in 1..item_table.count
               loop
                    if (item_table(i).subcat_id = l_cur_cat_id ) then
                            distinct_item := i ;
                    exit;
                    end if;
               end loop;
               if ( distinct_item = 0 ) then
                l_item_cnt := l_item_cnt +1;
                item_table(l_item_cnt).subcat_id := l_cur_cat_id;
                item_table(l_item_cnt).item_id := -1;
                item_table(l_item_cnt).stmt_id := p_stmt_id;
               end if;
               END IF;
             -- end  of Stk Ext
              OPEN c_cat_hrchy (l_cur_cat_id, p_stmt_id,p_period_id);

               LOOP
                  FETCH c_cat_hrchy
                   INTO cat_hrchy_rec;

                  EXIT WHEN c_cat_hrchy%NOTFOUND;

                  IF c_cat_hrchy%FOUND
                  THEN
                     subcat_count := subcat_hrchy_values.COUNT ;
                     subcat_hrchy_values(subcat_count +1 ).stmt_id:= p_stmt_id;
                     subcat_hrchy_values(subcat_count +1 ).cat_id:=cat_parent_rec.cat_id;
                     subcat_hrchy_values(subcat_count +1 ).subcat_id:=cat_hrchy_rec.sub_cat_id;
                     subcat_hrchy_values(subcat_count +1 ).lvl_num:=cat_hrchy_rec.lvl_num + 1;
                     subcat_hrchy_values(subcat_count +1 ).row_cat_id:=cat_parent_rec.row_in_cat_id;
                     subcat_hrchy_values(subcat_count +1 ).perd_id:=p_period_id;

                     INSERT INTO ben_tcs_cat_subcat_hrchy
                                 (stmt_id, cat_id,
                                  sub_cat_id,
                                  lvl_num,
                                  row_in_cat_id ,stmt_perd_id
                                 )
                          VALUES (p_stmt_id, cat_parent_rec.cat_id,
                                  cat_hrchy_rec.sub_cat_id,
                                  cat_hrchy_rec.lvl_num + 1,
                                  cat_parent_rec.row_in_cat_id,
                                  p_period_id
                                 );
                  END IF;
               END LOOP;
               WRITE('After processing  all  subcategories ..') ;
               CLOSE c_cat_hrchy;

               OPEN c_item_hrchy (l_cur_cat_id, p_stmt_id,p_period_id);
                LOOP
                  FETCH c_item_hrchy
                   INTO item_hrchy_rec;


                  EXIT WHEN c_item_hrchy%NOTFOUND;

                  IF c_item_hrchy%FOUND
                  THEN
                        item_count := item_hrchy_values.COUNT ;
                        item_hrchy_values(item_count +1 ).stmt_id:= p_stmt_id;
                        item_hrchy_values(item_count +1 ).cat_id:=cat_parent_rec.cat_id;
                        item_hrchy_values(item_count +1 ).item_id:=item_hrchy_rec.item_id;
                        item_hrchy_values(item_count +1 ).lvl_num:=item_hrchy_rec.lvl_num + 1;
                        item_hrchy_values(item_count +1 ).cntr_cd := item_hrchy_rec.cntr_cd ;
                        item_hrchy_values(item_count +1 ).row_cat_id := cat_parent_rec.row_in_cat_id;
                        item_hrchy_values(item_count +1 ).all_objects_id := cat_parent_rec.all_objects_in_cat_id;
                        item_hrchy_values(item_count +1 ).perd_id := p_period_id;

                       INSERT INTO ben_tcs_cat_item_hrchy
                                 (stmt_id, cat_id,
                                  item_id,
                                  lvl_num ,cntr_cd, row_in_cat_id ,all_objects_in_cat_id,stmt_perd_id
                                 )
                          VALUES (p_stmt_id, cat_parent_rec.cat_id,
                                  item_hrchy_rec.item_id,
                                  item_hrchy_rec.lvl_num + 1,
                                  item_hrchy_rec.cntr_cd,
                                  cat_parent_rec.row_in_cat_id,
                                  cat_parent_rec.all_objects_in_cat_id ,
                                  p_period_id
                                 );

                 END IF;
               END LOOP;
               CLOSE c_item_hrchy;
            END IF;
            end if;
         END LOOP;
         CLOSE c_cat_parent;
         end if ;
          l_cur_row := l_cur_row - 1;
      END LOOP;

   ROLLBACK TO hrchy;
      FOR i IN 1..item_table.COUNT
      LOOP
        WRITE(' in hierarchy items to be processed stmt id : '||p_stmt_id || 'item id  is : '||item_table(i).item_id ) ;
        INSERT INTO ben_tcs_cat_item_hrchy
                                 (stmt_id, cat_id,
                                  item_id,lvl_num,cntr_cd ,stmt_perd_id)
         VALUES (p_stmt_id ,-999 ,item_table(i).item_id ,-1 ,item_table(i).cntr_cd ,item_table(i).subcat_id  );

      END LOOP;
      p_item_hrchy_values := item_hrchy_values ;
      p_subcat_hrchy_values := subcat_hrchy_values ;
    EXCEPTION
         WHEN OTHERS THEN
                WRITE(SQLERRM);
                WRITE('Error in hierarchy generation');
    END obj_hrchy_gen;


   PROCEDURE stmt_gen_valid_process (p_stmt_id IN NUMBER, p_bg_id IN NUMBER ,
   p_period_id IN NUMBER  ,
   p_item_hrchy_values IN OUT NOCOPY cat_item_hrchy_table ,p_subcat_hrchy_values IN OUT  NOCOPY cat_subcat_hrchy_table ,
   p_status OUT NOCOPY Boolean )

   IS
      l_proc          VARCHAR2 (100)
                              := 'ben_tcs_stmt_valid_hrchy.stmt_gen_valid_process';
     BEGIN
               WRITE(l_proc);
               obj_hrchy_gen(p_stmt_id, p_bg_id ,p_period_id , p_item_hrchy_values ,p_subcat_hrchy_values);
               WRITE('after hierarchy generation....');
               p_status := true;
    EXCEPTION
    WHEN OTHERS THEN
        p_status := false;

   END stmt_gen_valid_process;


end BEN_TCS_STMT_VALID_HRCHY;

/
