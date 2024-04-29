--------------------------------------------------------
--  DDL for Package Body PON_OPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_OPT_PKG" as
/* $Header: PONOPTB.pls 120.0 2007/07/26 13:12:31 ukottama noship $ */

--
--private helper procedure for logging
PROCEDURE print_log (p_message  IN    VARCHAR2)
IS
BEGIN

   IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string(log_level => FND_LOG.level_statement,
                        module  =>  g_module_prefix,
                        message  => p_message);
      END IF;
   END IF;

END print_log;

PROCEDURE VERIFY_OPT_RESULT(p_scenario_id IN NUMBER
                           ,x_status    OUT NOCOPY VARCHAR2)
IS
x_total_award_quantity     NUMBER;
x_award_shipment_number    NUMBER;
l_matrix_index             NUMBER;
l_index                    NUMBER;
l_total_award_quantity     NUMBER;
l_bid_number               NUMBER;
l_line_number              NUMBER;
l_new_total_award_quantity NUMBER;
l_new_shipment_number      NUMBER;
l_new_award_price          NUMBER;
l_per_unit_price_component NUMBER;
l_po_total                 NUMBER;
l_scenario_total           NUMBER;

l_prob_lines t_prob_lines;

CURSOR  prob_opt_line(p_scenario_id NUMBER) IS
select distinct
por.scenario_id scenario_id,
por.bid_number bid_number,
por.line_number line_number,
sysdate AS CREATION_DATE,
por.CREATED_BY,
sysdate AS LAST_UPDATE_DATE,
por.LAST_UPDATED_BY,
por.LAST_UPDATE_LOGIN,
pbip.FIXED_AMOUNT_COMPONENT AS FIXED_AMOUNT_COMPONENT
  from pon.pon_optimize_results por,pon_bid_shipments pbs,
       pon_bid_item_prices pbip
  where por.scenario_id =p_scenario_id
  and pbs.bid_number = por.bid_number
  and pbs.line_number = por.line_number
  and pbs.shipment_number = por.award_shipment_number
  and ( (pbs.quantity > por.award_quantity) or
        (pbs.max_quantity < por.award_quantity))
  and pbip.bid_number = pbs.bid_number
  and pbip.line_number = pbs.line_number;

l_prob_opt_line prob_opt_line%ROWTYPE;

BEGIN
     l_matrix_index := 0;
     x_status := 'N'; -- set the initial status to N meaning that we
                      -- are not doing anything

     print_log('scenario_id: ' || p_scenario_id);

     open prob_opt_line(p_scenario_id);
     loop
        fetch prob_opt_line into l_prob_opt_line;
        EXIT WHEN prob_opt_line%NOTFOUND;


        l_matrix_index := l_matrix_index + 1;
        l_prob_lines(l_matrix_index).bid_number := l_prob_opt_line.bid_number;
        l_prob_lines(l_matrix_index).line_number := l_prob_opt_line.line_number;
        l_prob_lines(l_matrix_index).scenario_id := l_prob_opt_line.scenario_id;
        l_prob_lines(l_matrix_index).CREATION_DATE := l_prob_opt_line.CREATION_DATE;
        l_prob_lines(l_matrix_index).CREATED_BY := l_prob_opt_line.CREATED_BY;
        l_prob_lines(l_matrix_index).LAST_UPDATE_DATE := l_prob_opt_line.LAST_UPDATE_DATE;
        l_prob_lines(l_matrix_index).LAST_UPDATED_BY := l_prob_opt_line.LAST_UPDATED_BY;
        l_prob_lines(l_matrix_index).LAST_UPDATE_LOGIN := l_prob_opt_line.LAST_UPDATE_LOGIN;
        l_prob_lines(l_matrix_index).FIXED_AMOUNT_COMPONENT := l_prob_opt_line.FIXED_AMOUNT_COMPONENT;

     end loop; -- End of Fetch loop

     if ( l_matrix_index = 0) then
          x_status := 'N';
          print_log(' No Rows to process');
           -- No need to do anything. Just Break.
     ELSE
          x_status := 'Y';
          print_log(' Rows to process');
     END IF;

     -- Looping through all problem bids/
         FOR l_index IN 1..l_matrix_index LOOP

              print_log(' Row = '||l_index);

              --DBMS_OUTPUT.PUT_LINE('Row = '||l_index);

              select sum(award_quantity)
              into l_total_award_quantity
              from pon.pon_optimize_results
              where bid_number = l_prob_lines(l_index).bid_number
              and line_number = l_prob_lines(l_index).line_number
              and scenario_id = p_scenario_id;

              l_new_shipment_number := -1;
              l_new_total_award_quantity := -1;

              print_log(' bid_number = '||l_prob_lines(l_index).bid_number);
              print_log(' line_number = '||l_prob_lines(l_index).line_number);
              print_log('award qt '||l_total_award_quantity);

              --DBMS_OUTPUT.PUT_LINE(' bid_number = '||l_prob_lines(l_index).bid_number);
              --DBMS_OUTPUT.PUT_LINE(' line_number = '||l_prob_lines(l_index).line_number);
              --DBMS_OUTPUT.PUT_LINE('award qt '||l_total_award_quantity);

	      BEGIN
              print_log(' Trying Exact Match l_new_shipment_number');
		 select shipment_number,per_unit_price_component
                     into l_new_shipment_number,l_per_unit_price_component
                     from pon_bid_shipments
                     where quantity <= l_total_award_quantity
                     and max_quantity >= l_total_award_quantity
                     and bid_number = l_prob_lines(l_index).bid_number
                     and line_number = l_prob_lines(l_index).line_number;
              print_log(' Exact Match found - l_new_shipment_number  = '||l_new_shipment_number);
	      --  Exact Match Found
              l_new_total_award_quantity := l_total_award_quantity;


              EXCEPTION
              -- No Exact Match Found
		 WHEN NO_DATA_FOUND THEN
		 BEGIN
                 select max_quantity,shipment_number,
                      per_unit_price_component
                 into l_new_total_award_quantity,l_new_shipment_number,
                      l_per_unit_price_component
                 from pon_bid_shipments pbs1
  	         where pbs1.max_quantity =
		     (SELECT MAX(max_quantity)
		      FROM pon_bid_shipments pbs2
		      WHERE pbs2.max_quantity < l_total_award_quantity
		      and pbs2.bid_number = l_prob_lines(l_index).bid_number
		      and pbs2.line_number = l_prob_lines(l_index).line_number)
		 and pbs1.bid_number = l_prob_lines(l_index).bid_number
                 and pbs1.line_number = l_prob_lines(l_index).line_number;

                 print_log(' Not Exact Match l_new_shipment_number  = '||l_new_shipment_number);
                 print_log(' Not Exact Match l_new_total_award_quantity  = '||l_new_total_award_quantity);

		 EXCEPTION
		    WHEN no_data_found THEN
                      print_log(' No tier can be found for this qty ');
                      l_new_shipment_number := -1;
		 END;
              END;


              -- Calculate the new Award Price.
	      IF (l_new_shipment_number <> -1) THEN
                l_prob_lines(l_index).award_price := l_per_unit_price_component + (l_prob_lines(l_index).fixed_amount_component/l_new_total_award_quantity);
                l_prob_lines(l_index).award_quantity := l_new_total_award_quantity;
                l_prob_lines(l_index).award_shipment_number := l_new_shipment_number;

                print_log(' New award_price  = '||l_prob_lines(l_index).award_price);
                print_log(' New shipment_number  = '||l_prob_lines(l_index).award_shipment_number);
              END IF;

              -- Delete from pon_optimize_results errenous rows.
              delete from pon_optimize_results
              where bid_number = l_prob_lines(l_index).bid_number
              and line_number = l_prob_lines(l_index).line_number;

              --DBMS_OUTPUT.PUT_LINE(' After Delete ');
              -- Insert the new row with calculated quantity and shipment_number
              IF (l_new_shipment_number <> -1) THEN
                insert into pon_optimize_results(
                           SCENARIO_ID ,
                           BID_NUMBER,
                           LINE_NUMBER,
                           AWARD_QUANTITY,
                           AWARD_PRICE,
                           CREATION_DATE,
                           CREATED_BY,
                           LAST_UPDATE_DATE,
                           LAST_UPDATED_BY,
                           LAST_UPDATE_LOGIN,
                           AWARD_SHIPMENT_NUMBER,
                           INDICATOR_VALUE)
                 values (
                           p_scenario_id,
                           l_prob_lines(l_index).BID_NUMBER,
                           l_prob_lines(l_index).LINE_NUMBER,
                           l_prob_lines(l_index).AWARD_QUANTITY,
                           l_prob_lines(l_index).AWARD_PRICE,
                           sysdate,
                           l_prob_lines(l_index).CREATED_BY,
                           sysdate,
                           l_prob_lines(l_index).LAST_UPDATED_BY,
                           l_prob_lines(l_index).LAST_UPDATE_LOGIN,
                           nvl(l_prob_lines(l_index).AWARD_SHIPMENT_NUMBER,-1),
                           1);
              END IF;

              --DBMS_OUTPUT.PUT_LINE(' After Nsert ');

         END LOOP; -- End of Bid Line loop for problem Bid Lines.


         -- To Calculate the Scenario_total
       if ( x_status = 'Y') THEN
         print_log(' Calculating Scenario and po_total');

         select sum(por.AWARD_QUANTITY * por.award_price) as scenario_total,
                sum(por.award_quantity*nvl2(por.award_shipment_number,pbs.unit_price,pbip.unit_price)) as po_total
         into l_po_total,l_scenario_total
         from pon.pon_optimize_results por,pon_bid_shipments pbs
              ,pon_bid_item_prices pbip
         where por.scenario_id = p_scenario_id
         and pbs.bid_number(+) = por.bid_number
         and pbs.line_number(+) = por.line_number
         and pbs.shipment_number(+) = por.award_shipment_number
         and pbip.bid_number = pbs.bid_number
         and pbip.line_number = pbs.line_number;

         print_log('  Scenario total '||l_scenario_total);
         print_log('  PO total '||l_po_total);

         -- Update the Scenario Table with the total.
         update pon_optimize_scenarios
         set TOTAL_AWARD_AMOUNT = l_scenario_total,
             TOTAL_PO_AMOUNT = l_po_total
         where SCENARIO_ID = p_scenario_id;
      END IF;

         print_log(' At the very end  Status '||x_status);

END VERIFY_OPT_RESULT;


END PON_OPT_PKG;

/
