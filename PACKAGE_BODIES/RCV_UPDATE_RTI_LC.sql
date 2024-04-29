--------------------------------------------------------
--  DDL for Package Body RCV_UPDATE_RTI_LC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_UPDATE_RTI_LC" AS
/* $Header: RCVUPLCB.pls 120.1.12010000.7 2012/02/17 09:43:19 ksivasa noship $ */

  PROCEDURE  update_rti (p_int_rec        IN  rcv_cost_table,
                         x_lcm_int        OUT NOCOPY lcm_int_table) IS
  PRAGMA AUTONOMOUS_TRANSACTION;

     l_row_count                NUMBER := 0;
     l_group_id                 NUMBER;
     l_req_id                   NUMBER := 0;
     l_lpn_group_rti_count      NUMBER;
     callRTP                    BOOLEAN := FALSE;
     l_lpn_group_id             NUMBER;
     g_fail_if_one_line_fails   VARCHAR2(1);
     l_asn_type                 VARCHAR2(500);
     l_header_interface_id      NUMBER;
     l_rhi_group_id             NUMBER;
     l_lcm_int                  lcm_int_table := lcm_int_table();
     k                          NUMBER := 0;

     BEGIN

	--
        x_lcm_int := lcm_int_table();

	asn_debug.put_line('Entering UPDATE_RTI_WITH_LC.update_rti' || to_char(sysdate,'DD-MON-YYYY HH:MI:SS'));
        asn_debug.put_line('no of records to be updated : ' || p_int_rec.COUNT);
        --

	g_fail_if_one_line_fails := nvl(fnd_profile.VALUE('RCV_FAIL_IF_LINE_FAILS'),'N');

	asn_debug.put_line('profile RCV_FAIL_IF_LINE_FAILS: ' || g_fail_if_one_line_fails);

	SELECT rcv_interface_groups_s.NEXTVAL
          INTO l_group_id
        FROM DUAL;

	asn_debug.put_line('group_id to be updated with: ' || l_group_id);

        for i in 1..p_int_rec.COUNT loop

          if (p_int_rec(i).unit_landed_cost is not null
	      and p_int_rec(i).lcm_shipment_line_id is not null
	      and p_int_rec(i).interface_id is not null) then

            UPDATE rcv_transactions_interface
              SET lcm_shipment_line_id = p_int_rec(i).lcm_shipment_line_id,
                  unit_landed_cost =  p_int_rec(i).unit_landed_cost
            WHERE interface_transaction_id = p_int_rec(i).interface_id
	      AND processing_status_code = 'LC_INTERFACED'
	      AND lcm_shipment_line_id is NULL
	      AND unit_landed_cost is NULL;

            l_row_count := l_row_count + SQL%ROWCOUNT;

	    asn_debug.put_line('updated interface id: ' || p_int_rec(i).interface_id);
	    asn_debug.put_line('Updated : '||SQL%ROWCOUNT||' rows in RTI');

            if (SQL%ROWCOUNT > 0) then
	       k := k+1;
	       x_lcm_int.extend;
	       x_lcm_int(k) := p_int_rec(i).interface_id;
	    end if;

	  else
	    asn_debug.put_line('did not update interface id: ' || p_int_rec(i).interface_id);
	    asn_debug.put_line('unit_landed_cost: ' || p_int_rec(i).unit_landed_cost);
	    asn_debug.put_line('lcm_shipment_line_id: ' || p_int_rec(i).lcm_shipment_line_id);
	    asn_debug.put_line('interface_id: ' || p_int_rec(i).interface_id);

	  end if;

        end loop;

	asn_debug.put_line('Updated : '||l_row_count||' rows in RTI');

        l_lpn_group_rti_count := 0;
	for i in 1..p_int_rec.COUNT loop

	  begin
	     select lpn_group_id
	       into l_lpn_group_id
	     from rcv_transactions_interface
	     where interface_transaction_id = p_int_rec(i).interface_id;
	  exception
	     when others then
	        l_lpn_group_id := NULL;
	  end;

	  -- /* If a non-lcm line and lcm line are tied to the same lpn_group_id, we
	  --   need to set the non-lcm line to 'LC_PENDING' as these should be processed together.
	  -- */

	  asn_debug.put_line('lpn_group_id: '||l_lpn_group_id);

          IF (l_lpn_group_id IS NOT NULL) THEN

		select count(1)
		into   l_lpn_group_rti_count
		from   rcv_transactions_interface
		where  lpn_group_id = l_lpn_group_id
	        and    (lcm_shipment_line_id is NULL OR unit_landed_cost is NULL)
		and    processing_status_code in ('LC_PENDING','LC_INTERFACED');

		asn_debug.put_line('LPN Group check : l_lpn_group_rti_count = ' ||l_lpn_group_rti_count);

		if (l_lpn_group_rti_count = 0) then

                  UPDATE rcv_transactions_interface
                     SET processing_status_code = 'PENDING',
		         group_id = l_group_id
                  WHERE lpn_group_id = l_lpn_group_id
	          and ( ( lcm_shipment_line_id is not NULL
		         and unit_landed_cost is not NULL
		         and processing_status_code = 'LC_INTERFACED'
		        )
                        OR processing_status_code = 'WLC_PENDING'
		      );

                  UPDATE rcv_headers_interface rhi
                     SET rhi.processing_status_code = 'PENDING',
                         group_id = l_group_id -- Bug 7677015
                  WHERE rhi.processing_status_code <> 'RUNNING'
	          and exists( select 'exists' from rcv_transactions_interface rti
                              WHERE rti.lpn_group_id = l_lpn_group_id
			      and rti.header_interface_id IS NOT NULL
			      and rti.header_interface_id = rhi.header_interface_id
	                      and ( ( rti.lcm_shipment_line_id is not NULL
		                      and rti.unit_landed_cost is not NULL
		                      and rti.processing_status_code = 'PENDING' -- Bug 7677015
		                     )
                                     OR rti.processing_status_code = 'WLC_PENDING'

		                   )
		              );

		  asn_debug.put_line('no of rtis updated: '||sql%rowcount||' for the lpn group id: '||l_lpn_group_id);
	          callRTP := TRUE;

	        end if;
          else

                begin
		    select rhi.asn_type, rhi.header_interface_id, rhi.group_id
		      into l_asn_type, l_header_interface_id, l_rhi_group_id
		    from rcv_transactions_interface rti, rcv_headers_interface rhi
		    where rhi.header_interface_id = rti.header_interface_id
		    and rti.interface_transaction_id = p_int_rec(i).interface_id;
		exception
		    when others then
		       l_asn_type := 'NON-ASN';
		       l_header_interface_id := -9999;
		       l_rhi_group_id := -9999;
		end;

		asn_debug.put_line('asn_type = ' ||l_asn_type);
		asn_debug.put_line('header_interface_id = ' ||l_header_interface_id);
		asn_debug.put_line('rhi_group_id = ' ||l_rhi_group_id);

		IF (l_asn_type = 'ASN'
		    AND g_fail_if_one_line_fails = 'Y') THEN
                          select count(1)
                          into   l_lpn_group_rti_count
                          from   rcv_transactions_interface
                          where  header_interface_id = l_header_interface_id
			  and    group_id = l_rhi_group_id
	                  and    (lcm_shipment_line_id is NULL OR unit_landed_cost is NULL)
		          and    processing_status_code in ('LC_PENDING','LC_INTERFACED');

			  asn_debug.put_line('ASN check : l_lpn_group_rti_count = ' ||l_lpn_group_rti_count);


		          if (l_lpn_group_rti_count = 0) then

                            UPDATE rcv_transactions_interface
                               SET processing_status_code = 'PENDING',
		                   group_id = l_group_id
                            WHERE  header_interface_id = l_header_interface_id
		            AND    group_id = l_rhi_group_id
	                    and    (( lcm_shipment_line_id is not NULL
			              and unit_landed_cost is not NULL
			              and processing_status_code = 'LC_INTERFACED'
				     )
                                     OR processing_status_code = 'WLC_PENDING'
				   );

                            UPDATE rcv_headers_interface rhi
                               SET rhi.processing_status_code = 'PENDING',
                                   group_id = l_group_id -- Bug 7677015
                             WHERE rhi.processing_status_code <> 'RUNNING'
	                     and exists( select 'exists' from rcv_transactions_interface rti
                                         WHERE rti.header_interface_id = rhi.header_interface_id
					 and rti.header_interface_id = l_header_interface_id
		                         and group_id = l_rhi_group_id
	                                 and ( ( rti.lcm_shipment_line_id is not NULL
		                                 and rti.unit_landed_cost is not NULL
		                                 and rti.processing_status_code = 'PENDING' -- Bug 7677015
		                                )
                                                OR rti.processing_status_code = 'WLC_PENDING'

		                              )
		                        );

			    asn_debug.put_line('rtis updated: '||sql%rowcount||' for the header interface id: '||l_header_interface_id);
			    callRTP := TRUE;

		          end if;
	         ELSE
                          UPDATE rcv_transactions_interface
                             SET processing_status_code = 'PENDING',
		                 group_id = l_group_id
                          WHERE  interface_transaction_id = p_int_rec(i).interface_id
	                  AND    processing_status_code = 'LC_INTERFACED'
                          and    lcm_shipment_line_id is not NULL
			  and    unit_landed_cost is not NULL;


			  UPDATE rcv_headers_interface rhi
                             SET rhi.processing_status_code = 'PENDING',
                                 group_id = l_group_id -- Bug 7677015
                          WHERE rhi.processing_status_code <> 'RUNNING'
	                  and exists( select 'exists' from rcv_transactions_interface rti
                                      WHERE rti.interface_transaction_id = p_int_rec(i).interface_id
			              and rti.header_interface_id IS NOT NULL
				      and rti.header_interface_id = rhi.header_interface_id
	                              AND    processing_status_code = 'PENDING' -- Bug 7677015
                                      and    lcm_shipment_line_id is not NULL
			              and    unit_landed_cost is not NULL
		                    );

			  asn_debug.put_line('rti updated for the interface id: '||p_int_rec(i).interface_id);
		          callRTP := TRUE;
		 END IF;

	  end if;

        end loop;

	if (callRTP) then

	   COMMIT;
	   asn_debug.put_line('calling RTP for group id: '||l_group_id);
	   l_req_id := fnd_request.submit_request('PO', 'RVCTP',null,null,false,'BATCH',l_group_id,'0',NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
           NULL, NULL, NULL, NULL, NULL, NULL);

	   asn_debug.put_line('request id: '||l_req_id, 'insertlcm', '9');

	   if (l_req_id <= 0 or l_req_id is null) then
	      raise fnd_api.g_exc_unexpected_error;
	   end if;

	end if;

	COMMIT;

     EXCEPTION
        WHEN OTHERS THEN

	  asn_debug.put_line('encountered an error in update_rti:  ' || sqlcode ||' '||substr(SQLERRM, 1, 1000));
	  asn_debug.put_line('Updated : '||l_row_count||' rows in RTI');

          COMMIT;

     END update_rti;

END RCV_UPDATE_RTI_LC;


/
