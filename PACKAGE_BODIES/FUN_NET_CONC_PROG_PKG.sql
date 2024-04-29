--------------------------------------------------------
--  DDL for Package Body FUN_NET_CONC_PROG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_NET_CONC_PROG_PKG" AS
/* $Header: funntcpb.pls 120.2.12010000.2 2008/08/06 07:46:35 makansal ship $ */

    PROCEDURE Create_Net_Batch(
        errbuf  OUT NOCOPY VARCHAR2,
        retcode OUT NOCOPY VARCHAR2,
        p_batch_id IN fun_net_batches_all.batch_id%TYPE) IS

        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);

    BEGIN
        fun_net_util.log_string(1,'fun_net_conc_prog_pkg.create_net_batch','Before calling create batch API');
        FUN_NET_ARAP_PKG.create_net_batch(
                    p_init_msg_list => FND_API.G_TRUE,
                    p_commit        => FND_API.G_TRUE,
                    x_return_status => l_return_status,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data,
                    p_batch_id      => p_batch_id);
        fun_net_util.log_string(1,'fun_net_conc_prog_pkg.create_net_batch','return from create batch API');
        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            fun_net_util.log_string(1,'fun_net_conc_prog_pkg.create_net_batch','Success');
            retcode := 0;
        ELSE
            fun_net_util.log_string(1,'fun_net_conc_prog_pkg.create_net_batch','Error');
            retcode := 2;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            retcode := 2;
            errbuf := sqlerrm;
    END Create_Net_Batch;

    PROCEDURE Submit_Net_Batch(
        errbuf  OUT NOCOPY VARCHAR2,
        retcode OUT NOCOPY VARCHAR2,
        p_batch_id IN fun_net_batches_all.batch_id%TYPE) IS

        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);

    BEGIN
        retcode := 0;
        FUN_NET_ARAP_PKG.submit_net_batch (
                        p_init_msg_list => FND_API.G_FALSE,
                        p_commit        => FND_API.G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        p_batch_id      => p_batch_id);
        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            retcode := 0;
            RETURN;
        ELSE
            LOOP
                errbuf := FND_MESSAGE.GET;
                IF errbuf IS NULL THEN
                    EXIT;
                ELSE
                 FND_FILE.PUT_LINE(FND_FILE.LOG,errbuf);
                 FND_FILE.NEW_LINE(FND_FILE.LOG,1);
                END IF;
            END LOOP;

            retcode := 2;
            RETURN;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            retcode := 2;
            errbuf := sqlerrm;
    END Submit_Net_Batch;

    PROCEDURE Settle_Net_Batch(
        errbuf  OUT NOCOPY VARCHAR2,
        retcode OUT NOCOPY VARCHAR2,
        p_batch_id IN fun_net_batches_all.batch_id%TYPE) IS

        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
    BEGIN
        retcode := 0;
        FUN_NET_ARAP_PKG.settle_net_batch (
            -- ***** Standard API Parameters *****
            p_init_msg_list     => FND_API.G_TRUE,
            p_commit            => FND_API.G_TRUE,
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data,
            -- ***** Netting batch input parameters *****
            p_batch_id          => p_batch_id);

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            retcode := 0;
            RETURN;
        ELSE
           LOOP
                errbuf := FND_MESSAGE.GET;
                IF errbuf IS NULL THEN
                    EXIT;
                ELSE
                 FND_FILE.PUT_LINE(FND_FILE.LOG,errbuf);
                 FND_FILE.NEW_LINE(FND_FILE.LOG,1);
                END IF;
            END LOOP;

            retcode := 2;
            RETURN;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            retcode := 2;
            errbuf := sqlerrm;
    END Settle_Net_Batch;

    PROCEDURE Reverse_Net_Batch(
        errbuf  OUT NOCOPY VARCHAR2,
        retcode OUT NOCOPY VARCHAR2,
        p_batch_id IN fun_net_batches_all.batch_id%TYPE) IS

        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
    BEGIN
        retcode := 0;
        FUN_NET_CANCEL_PKG.reverse_net_batch (
            -- ***** Standard API Parameters *****
            p_init_msg_list     => FND_API.G_TRUE,
            p_commit            => FND_API.G_TRUE,
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data,
            -- ***** Netting batch input parameters *****
            p_batch_id          => p_batch_id);

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            retcode := 0;
            RETURN;
        ELSE
           LOOP
                errbuf := FND_MESSAGE.GET;
                IF errbuf IS NULL THEN
                    EXIT;
                ELSE
                 FND_FILE.PUT_LINE(FND_FILE.LOG,errbuf);
                 FND_FILE.NEW_LINE(FND_FILE.LOG,1);
                END IF;
            END LOOP;

            retcode := 2;
            RETURN;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            retcode := 2;
            errbuf := sqlerrm;
    END Reverse_Net_Batch;
END FUN_NET_CONC_PROG_PKG;

/
