--------------------------------------------------------
--  DDL for Package Body OKS_RENEW_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_RENEW_CONTRACT_PVT" AS
/* $Header: OKSRRENKB.pls 120.24.12010000.3 2009/11/05 12:53:03 spingali ship $*/

------------------------ Internal Type Declarations ---------------------------------
TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE date_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE chr_tbl_type IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
------------------------ Start Internal procedures ----------------------------------

    /* Internal function, determines the end date of the renewed contract */

    FUNCTION GET_END_DATE
    (
     p_new_start_date IN DATE,
     p_new_end_date IN DATE,
     p_new_duration IN NUMBER,
     p_new_uom_code IN MTL_UNITS_OF_MEASURE_TL.uom_code%TYPE,
     p_old_start_date IN DATE,
     p_old_end_date IN DATE,
     p_renewal_end_date IN DATE,
     p_ren_type  IN okc_k_headers_b.renewal_type_code%TYPE,
     x_return_status OUT NOCOPY VARCHAR2
    )RETURN DATE
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'GET_END_DATE';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR(512);

    l_end_date DATE;
    l_duration NUMBER;
    l_uom_code MTL_UNITS_OF_MEASURE_TL.uom_code%TYPE;
    BEGIN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_new_start_date='||p_new_start_date||' ,p_new_end_date='||p_new_end_date||' ,p_new_duration='||p_new_duration||' ,p_new_uom_code='||p_new_uom_code||
            ' , p_old_start_date='||p_old_start_date||' ,p_old_end_date='||p_old_end_date||' ,p_renewal_end_date='||p_renewal_end_date||' ,p_ren_type='||p_ren_type);
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --trivial case, end date is given
        l_end_date := trunc(p_new_end_date);

        --if end date is null determine it from duration/period
        IF (l_end_date IS NULL) THEN

            l_duration := p_new_duration;
            l_uom_code := p_new_uom_code;
            --if duration/period are also null, use the old contract's duration period
            IF(l_duration IS NULL OR l_uom_code IS NULL) THEN

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_duration', 'before call to   OKC_TIME_UTIL_PUB.get_duration p_start_date='||to_char(p_old_start_date)||' ,p_end_date='||to_char(p_old_end_date));
                END IF;

                OKC_TIME_UTIL_PUB.get_duration(
                    p_start_date => trunc(p_old_start_date),
                    p_end_date => trunc(p_old_end_date),
                    x_duration => l_duration,
                    x_timeunit => l_uom_code,
                    x_return_status => x_return_status);

                IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                END IF;

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_duration', 'after call to   OKC_TIME_UTIL_PUB.get_duration, l_duration='||l_duration||' ,l_uom_code='||l_uom_code);
                END IF;
            END IF; --of (l_duration IS NULL OR l_uom_code IS NULL) THEN

            --now determine the end date from duration/period
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.derive_end_date', 'before call to   OKC_TIME_UTIL_PUB.get_enddate, p_start_date='||to_char(p_new_start_date)||' ,p_timeunit='||l_uom_code||' ,p_duration='||l_duration);
            END IF;

            l_end_date := OKC_TIME_UTIL_PUB.get_enddate(
                                p_start_date => trunc(p_new_start_date),
                                p_timeunit => l_uom_code,
                                p_duration => l_duration);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.derive_end_date', 'after call to   OKC_TIME_UTIL_PUB.get_enddate, l_end_date='||to_char(l_end_date));
            END IF;

        END IF; --of IF (l_end_date IS NULL) THEN

        --Truncate the end date, if EVN and ultimate end date is specified and end date is
        --greater than ultimate end date
        IF (nvl(p_ren_type, 'X') = 'EVN') AND (p_renewal_end_date IS NOT NULL) THEN

            --first check that the ultimate end date should not be before the start date
            IF(trunc(p_renewal_end_date) < p_new_start_date) THEN

                FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_NEW_START_MORE_FINAL_END');
                FND_MESSAGE.set_token('START_DATE', to_char(trunc(p_new_start_date), 'DD-MON-YYYY'));
                FND_MESSAGE.set_token('REN_UP_TO_DATE', to_char(trunc(p_renewal_end_date), 'DD-MON-YYYY'));

                IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.message(FND_LOG.level_error, l_mod_name || '.derive_end_date', FALSE);
                END IF;
                FND_MSG_PUB.ADD;
                RAISE FND_API.g_exc_error;

            END IF;

            --now truncate end date to ultimate end date if required
            IF (trunc(l_end_date) > trunc(p_renewal_end_date)) THEN
                l_end_date := trunc(p_renewal_end_date);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.truncate', 'truncated end date, l_end_date='||to_char(l_end_date));
                END IF;
            END IF;

        END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', '  l_end_date='||to_char(l_end_date));
        END IF;

        RETURN l_end_date;
    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            RAISE;

    END GET_END_DATE;


    /* 	Internal Procedure
    This is a new module that will be called for all service contracts after copying the
    old contract. It will update the new contract header and lines start dates and end dates
    based on renewal type for the line (Full Duration, Keep Duration, Do not renew). It uses
    bulk operations to maximize performance. Since only start_date and end_date are updated in OKC_K_LINES_B and OKC_K_HEADERS_B, TAPI is ignored. It replaces the existing OKC procedure OKC_RENEW_PVT.update_renewal_dates.

    Parameters
        p_chr_id                :   id of the renewed contract
        p_new_start_date        :   header start date for the renewed contract
        p_new_end_date          :   header end date for the renewed contract
        p_old_end_date          :   header start date for the source contract
    */

    PROCEDURE UPDATE_RENEWAL_DATES
    (
     p_chr_id  IN NUMBER,
     p_new_start_date IN DATE,
     p_new_end_date IN DATE,
     p_old_start_date IN DATE,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS
	TYPE line_rec IS RECORD
		(id			    NUMBER,
		cle_id			NUMBER,
		lrt			    okc_k_lines_b.line_renewal_type_code%TYPE,
		old_start_date	DATE,
		old_end_date	DATE,
		new_start_date	DATE,
		new_end_date	DATE);

	TYPE line_rec_tbl_type IS TABLE OF line_rec INDEX BY BINARY_INTEGER;

    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_RENEWAL_DATES';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    l_dummy			        NUMBER;
    l_lines_tbl		        line_rec_tbl_type;
	l_cached_tbl		    line_rec_tbl_type;
	l_id_tbl		        num_tbl_type;

	l_start_date_tbl	    date_tbl_type;
	l_end_date_tbl		    date_tbl_type;

	l_parent_new_start_date	DATE;
	l_parent_new_end_date	DATE;
	l_parent_old_start_date	DATE;
	l_parent_rec		    line_rec;

	l_additional_days	    NUMBER;
	l_duration		        NUMBER;



	cursor c_kep_lines(cp_chr_id IN NUMBER) IS
        SELECT id from okc_k_lines_b
        where dnz_chr_id = cp_chr_id and nvl(line_renewal_type_code,'X') = 'KEP';

    cursor c_lines(cp_chr_id in number) is
		select id, cle_id, line_renewal_type_code, start_date, end_date, null, null
		from okc_k_lines_b
		start with (dnz_chr_id = cp_chr_id and cle_id is null)
		connect by prior id = cle_id;


	-- this local function gets the parent line information
	FUNCTION GET_PARENT_REC(p_cle_id in number) return line_rec
	is
	l_rec		line_rec := null;
	BEGIN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.get_parent_rec.begin', 'p_cle_id='||p_cle_id);
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- first check the l_cached_tbl as it is going to be smaller or null
        IF (l_cached_tbl.count > 0) THEN
            for i in l_cached_tbl.first..l_cached_tbl.last loop
                if (l_cached_tbl(i).id = p_cle_id) then
                    l_rec := l_cached_tbl(i);
                end if;
            end loop;
        END IF;

		--now check the current lines_tbl
        IF (l_lines_tbl.count > 0) THEN
            for i in l_lines_tbl.first..l_lines_tbl.last loop
                if (l_lines_tbl(i).id = p_cle_id) then
                    l_rec := l_lines_tbl(i);
                end if;
            end loop;
        END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.get_parent_rec.end', 'l_rec.id='||l_rec.id||' ,l_rec.lrt='||l_rec.lrt);
        END IF;

		RETURN l_rec;
	END GET_PARENT_REC;

	--this local procedure populates all the parent lines of a given
	--line in l_cached_tbl. l_cached_tbl is used to preserve
	--parent line info across successive bulk fetches. It is called after
    --every bulk fecth cycle
	PROCEDURE POPULATE_CACHE(p_line_rec in line_rec)
	IS
	l_current_rec	    line_rec;
    l_cached_tbl_tmp    line_rec_tbl_type;
	n		            number;
	BEGIN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.populate_cache.begin', 'p_line_rec.id='||p_line_rec.id||' ,p_line_rec.cle_id='||p_line_rec.cle_id);
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

		l_current_rec := p_line_rec;
        --we will first populate a temp cache
        l_cached_tbl_tmp.delete;
		l_cached_tbl_tmp(1) := l_current_rec;

		loop
			if (l_current_rec.cle_id is null) then
                --this is a top line, so no more parents
				exit;
			else
                --get the parent rec from l_cached_tbl/l_lines_tbl
				l_current_rec := get_parent_rec(l_current_rec.cle_id);
				if (l_current_rec.id is not null) then
					--add it to the bottom of l_cached_tbl_tmp
                    n := l_cached_tbl_tmp.count;
					l_cached_tbl_tmp(n+1) := l_current_rec;
				end if;
			end if;
		end loop;

        --now use the temp cache as the real cache for the next bulk fetch cycle
        l_cached_tbl := l_cached_tbl_tmp;
	    l_cached_tbl_tmp.delete;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.populate_cache.end', 'l_cached_tbl.count='||l_cached_tbl.count);
        END IF;

	end POPULATE_CACHE;

    --this local procedure deletes any DNR top lines and child lines and any associated entities
    --this is only necessary till the new copy API begins to filter out DNR lines for renewal
    --commented this procedure as the new copy API is taking care of this
    /*
    PROCEDURE DELETE_DNR_LINES
    IS

	cursor c_dnr_lines(cp_chr_id in number) is
		select id from okc_k_lines_b
		where dnz_chr_id = cp_chr_id and nvl(line_renewal_type_code,'X') = 'DNR';

    l_dnr_lines_tbl		    num_tbl_type;

    BEGIN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.delete_dnr_lines.begin', 'p_chr_id='||p_chr_id);
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        open c_dnr_lines(p_chr_id);
        loop
            fetch c_dnr_lines bulk collect into l_dnr_lines_tbl limit G_BULK_FETCH_LIMIT;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_dnr_lines.bulk_fetch', 'l_dnr_lines_tbl.count='||l_dnr_lines_tbl.count);
            END IF;

            exit when (l_dnr_lines_tbl.count = 0);

            for i in l_dnr_lines_tbl.first..l_dnr_lines_tbl.last loop
                -- this will delete all associated okc/oks lines
                -- and other entiries such as billing schedule, coverages etc
                -- OKC code was not doing this

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_dnr_lines.delete_line', 'calling delete_contract_line, p_line_id='||l_dnr_lines_tbl(i)||' x_return_status='||x_return_status);
                END IF;
                delete_contract_line(
                        p_api_version => 1,
                        p_init_msg_list => FND_API.G_FALSE,
                        p_commit => FND_API.G_FALSE,
                        p_line_id => l_dnr_lines_tbl(i),
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_dnr_lines.delete_line', 'after call to delete_contract_line, x_return_status='||x_return_status);
                END IF;

                IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                END IF;

            END LOOP;

        END LOOP;
        CLOSE c_dnr_lines;
        l_dnr_lines_tbl.delete;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.delete_dnr_lines.end', 'x_return_status='||x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.delete_dnr_lines.end_error', 'x_return_status=' || x_return_status);
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.delete_dnr_lines.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.delete_dnr_lines.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_dnr_lines%isopen) THEN
                CLOSE c_dnr_lines;
            END IF;
            RAISE;

    END DELETE_DNR_LINES;
    */

    BEGIN
        --main update procedure begins here
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id='||p_chr_id||' ,p_new_start_date='||p_new_start_date||' ,p_new_end_date='||p_new_end_date||'  ,p_old_start_date='||p_old_start_date);
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --becuase of bug 2689096, we need to capture the time component also for each
        --start date and end date
        --If time component is nulled out, duration can be different and this  will affect pricing

        --first update contract header
        update okc_k_headers_all_b SET
            start_date = to_date(to_char(p_new_start_date, 'DD/MM/YYYY')|| to_char(start_date,'HH24:MI:SS'), 'DD/MM/YYYYHH24:MI:SS'),
            end_date = to_date(to_char(p_new_end_date, 'DD/MM/YYYY')|| to_char(end_date,'HH24:MI:SS'), 'DD/MM/YYYYHH24:MI:SS')
            WHERE id = p_chr_id;

        --delete DNR lines
        --commented this call as the new copy API is taking care of this
        --delete_dnr_lines;


        --now check if there are any Keep Duraton lines, if there are no Keep Duration lines
        --a simple update will do
        open c_kep_lines(p_chr_id);
        fetch c_kep_lines into l_dummy;
        close c_kep_lines;

        --no keep duration lines
        IF (l_dummy IS NULL) THEN
            UPDATE okc_k_lines_b SET
            start_date = to_date(to_char(p_new_start_date, 'DD/MM/YYYY')|| to_char(start_date,'HH24:MI:SS'), 'DD/MM/YYYYHH24:MI:SS'),
            end_date = to_date(to_char(p_new_end_date, 'DD/MM/YYYY')|| to_char(end_date,'HH24:MI:SS'), 'DD/MM/YYYYHH24:MI:SS')
            WHERE dnz_chr_id = p_chr_id;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.check_keep', 'end  no keep duration lines, done with date updates ,x_return_status='||x_return_status);
            END IF;
            RETURN;

        END IF;


        --we come to this step only if there are some keep duration lines
        OPEN c_lines(p_chr_id);
        LOOP
            --fetch okc lines in heirarchial order
            FETCH c_lines BULK COLLECT INTO l_lines_tbl LIMIT G_BULK_FETCH_LIMIT;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.c_lines_bulk_fetch', 'l_lines_tbl.count='||l_lines_tbl.count);
            END IF;

            EXIT WHEN (l_lines_tbl.count = 0);

            for i in l_lines_tbl.first..l_lines_tbl.last loop

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calc_dates_begin', 'i='||i||' ,l_lines_tbl(i).cle_id='||l_lines_tbl(i).cle_id);
                END IF;

                --determine the parent lrt and parent dates
                --for top lines
                if l_lines_tbl(i).cle_id is null then
                    --always set the current line's lrt
                    l_lines_tbl(i).lrt := nvl(l_lines_tbl(i).lrt, 'FUL');
                    -- for toplines the parent is the contract header
                    l_parent_new_start_date := trunc(p_new_start_date);
                    l_parent_new_end_date := trunc(p_new_end_date);
                    l_parent_old_start_date := trunc(p_old_start_date);
                -- for other lines
                else
                    l_parent_rec := get_parent_rec(l_lines_tbl(i).cle_id);
                    --always set the current line's lrt
                    l_lines_tbl(i).lrt := nvl(l_lines_tbl(i).lrt, l_parent_rec.lrt);
                    l_parent_new_start_date := trunc(l_parent_rec.new_start_date);
                    l_parent_new_end_date := trunc(l_parent_rec.new_end_date);
                    l_parent_old_start_date := trunc(l_parent_rec.old_start_date);
                end if; --of if lines_tbl(i).cle_id is null then


                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calc_dates_parent', 'i='||i||' ,l_parent_new_start_date='||l_parent_new_start_date||' ,l_parent_new_end_date='||l_parent_new_end_date);
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calc_dates_parent',' l_parent_old_start_date='||l_parent_old_start_date||' ,l_lines_tbl(i).lrt='||l_lines_tbl(i).lrt);
                END IF;

                --determine the new dates based on renewal type
                if l_lines_tbl(i).lrt = 'FUL' then
                    -- line dates are the same as parent dates
                    l_lines_tbl(i).new_start_date := trunc(l_parent_new_start_date);
                    l_lines_tbl(i).new_end_date := trunc(l_parent_new_end_date);

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calc_dates_FUL', 'i='||i||' ,l_lines_tbl(i).new_start_date='||l_lines_tbl(i).new_start_date||' ,l_lines_tbl(i).new_end_date='||l_lines_tbl(i).new_end_date);
                    END IF;

                elsif l_lines_tbl(i).lrt = 'KEP' then

                    --get the original start date offset
                    l_duration := 0;
                    l_additional_days := 0;

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calc_dates_KEP_1', 'i='||i||' calling OKC_TIME_UTIL_PVT.get_oracle_months_and_days, p_start_date='||l_parent_old_start_date||' ,p_end_date='||l_lines_tbl(i).old_start_date);
                    END IF;

                    OKC_TIME_UTIL_PVT.get_oracle_months_and_days(
                        p_start_date => trunc(l_parent_old_start_date),
                        p_end_date => trunc(l_lines_tbl(i).old_start_date),
                        x_month_duration => l_duration,
                        x_day_duration => l_additional_days,
                        x_return_status => x_return_status);

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calc_dates_KEP_1', 'i='||i||',after OKC_TIME_UTIL_PVT.get_oracle_months_and_days, x_return_status='||x_return_status||
                        ',x_mth_duration='||l_duration||',x_day_duration='||l_additional_days);
                    END IF;

                    IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                    ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                    END IF;

                    -- add the offset to parent start date
                    l_lines_tbl(i).new_start_date := ADD_MONTHS(
                        trunc(l_parent_new_start_date), l_duration) + l_additional_days;

                    if(trunc(l_lines_tbl(i).new_start_date) <= trunc(l_parent_new_end_date)) then

                        --get the original end date offset
                        l_duration := 0;
                        l_additional_days := 0;

                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calc_dates_KEP_2', 'i='||i||' calling OKC_TIME_UTIL_PVT.get_oracle_months_and_days, p_start_date='||l_parent_old_start_date||
                            ' ,p_end_date='||l_lines_tbl(i).old_end_date||' ,x_return_status='||x_return_status);
                        END IF;

                        OKC_TIME_UTIL_PVT.get_oracle_months_and_days(
                            p_start_date => trunc(l_parent_old_start_date),
                            p_end_date => trunc(l_lines_tbl(i).old_end_date),
                            x_month_duration => l_duration,
                            x_day_duration => l_additional_days,
                            x_return_status => x_return_status);

                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calc_dates_KEP_3', 'i='||i||'after OKC_TIME_UTIL_PVTget_oracle_months_and_days, x_return_status='||x_return_status||
                            ',x_mth_duration='||l_duration||',x_day_duration='||l_additional_days);
                        END IF;

                        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                            RAISE FND_API.g_exc_unexpected_error;
                        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                            RAISE FND_API.g_exc_error;
                        END IF;

                        -- add the offset to parent start date
                        l_lines_tbl(i).new_end_date := ADD_MONTHS(
                            trunc(l_parent_new_start_date), l_duration) + l_additional_days;

                        --chop line end date if it is greater than parent end date
                        if (trunc(l_lines_tbl(i).new_end_date) > trunc(l_parent_new_end_date)) then
                            l_lines_tbl(i).new_end_date := trunc(l_parent_new_end_date);

                            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calc_dates_KEP_4', 'i='||i||' chopped line end date, l_lines_tbl(i).new_end_date='||l_lines_tbl(i).new_end_date||
                                ' ,l_parent_new_end_date='||l_parent_new_end_date);
                            END IF;

                        end if;

                    --line is starting beyond the parent end date
                    else
                        --1 day renewal
                        l_lines_tbl(i).new_start_date := trunc(l_parent_new_start_date);
                        l_lines_tbl(i).new_end_date := trunc(l_parent_new_start_date);

                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calc_dates_KEP_5', 'i='||i||', 1 day renewal, l_lines_tbl(i).new_start_date > l_parent_new_end_date l_lines_tbl(i).new_st_date='||
                            l_lines_tbl(i).new_start_date||' ,l_parent_new_end_date='||l_parent_new_end_date);
                        END IF;

                    end if;
                end if; --of elsif lines_tbl(i).lrt = 'KEP' then

                --store in non-record pl/sql table for use in subsequent FORALL update
                l_id_tbl(i) := l_lines_tbl(i).id;
                l_start_date_tbl(i) := trunc(l_lines_tbl(i).new_start_date);
                l_end_date_tbl(i) := trunc(l_lines_tbl(i).new_end_date);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calc_dates_end', 'i='||i||' ,l_id_tbl(i)='||l_id_tbl(i)||' ,l_start_date_tbl(i)='||l_start_date_tbl(i)||' ,l_end_date_tbl(i)='||l_end_date_tbl(i));
                END IF;

            end loop; --of for i in l_lines_tbl.first..l_lines_tbl.last loop


            --now we have determined the new start/end dates of all the lines
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.forall_update_stmt ', 'l_id_tbl.count='||l_id_tbl.count||' ,x_return_status='||x_return_status);
            END IF;

            --becuase of bug 2689096, we need to capture the time component also for each
            --start date and end date
            --If time component is nulled out, duration can be different and this  will affect pricing
            forall i in l_id_tbl.first..l_id_tbl.last
                update okc_k_lines_b set
                    start_date = to_date(to_char(l_start_date_tbl(i), 'DD/MM/YYYY')|| to_char(start_date,'HH24:MI:SS'), 'DD/MM/YYYYHH24:MI:SS'),
                    end_date = to_date(to_char(l_end_date_tbl(i), 'DD/MM/YYYY')|| to_char(end_date,'HH24:MI:SS'), 'DD/MM/YYYYHH24:MI:SS')
                    where id =  l_id_tbl(i);

            l_id_tbl.delete;
            l_start_date_tbl.delete;
            l_end_date_tbl.delete;

            -- populate the cache for next bulk fetch
            -- this gets all the parents of the last record and stores them in a local table
            -- this is necessary to derive the parent for the lines obtained in the next bulk fetch.
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calling_populate_cache', 'l_lines_tbl(l_lines_tbl.last).id='||l_lines_tbl(l_lines_tbl.last).id||' ,x_return_status='||x_return_status);
            END IF;
            populate_cache(l_lines_tbl(l_lines_tbl.last));

        end loop; -- main bulk fetch limit loop
        close c_lines;
        l_lines_tbl.delete;
        l_id_tbl.delete;
        l_start_date_tbl.delete;
        l_end_date_tbl.delete;


        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='||x_return_status);
        END IF;

    EXCEPTION

        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_lines%isopen) THEN
                CLOSE c_lines;
            END IF;
            IF (c_kep_lines%isopen) THEN
                CLOSE c_kep_lines;
            END IF;

            RAISE;

    END UPDATE_RENEWAL_DATES;

    /*
    Internal procedure that updates the date_renewed column for the source contract header
    and the source contract lines are actually renewed (i.e., ignores any DNR lines)
    */
    PROCEDURE UPDATE_SOURCE_CONTRACT
    (
     p_new_chr_id  IN NUMBER,
     p_old_chr_id IN NUMBER,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS

    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_SOURCE_CONTRACT';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text    VARCHAR2(512);

	l_id_tbl num_tbl_type;
	l_date date := sysdate;

    --gets the line in the source contract for which the lines actualluy exist in the target
    --contract
    CURSOR c_old_lines(cp_new_chr_id IN NUMBER, cp_old_chr_id in number) IS
        SELECT okl.id
        FROM okc_k_lines_b okl, okc_operation_lines ol
        WHERE ol.object_chr_id = cp_old_chr_id
        AND ol.subject_chr_id = cp_new_chr_id
        AND ol.object_cle_id IS NOT NULL AND ol.subject_cle_id IS NOT NULL
        AND ol.process_flag = 'P' AND ol.active_yn = 'Y'
        AND ol.object_cle_id = okl.id AND okl.dnz_chr_id = cp_old_chr_id;

    BEGIN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_new_chr_id='||p_new_chr_id||' ,p_old_chr_id='||p_old_chr_id);
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;


		UPDATE okc_k_headers_all_b
            SET	date_renewed = l_date,
			    object_version_number = (object_version_number + 1)
			WHERE id = p_old_chr_id;

		OPEN c_old_lines(p_new_chr_id, p_old_chr_id);
		LOOP
			FETCH c_old_lines BULK COLLECT INTO l_id_tbl LIMIT G_BULK_FETCH_LIMIT;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.bulk_fetch', 'l_id_tbl.count='||l_id_tbl.count);
            END IF;

            EXIT WHEN (l_id_tbl.count = 0);

			FORALL i IN l_id_tbl.first..l_id_tbl.last
				UPDATE okc_k_lines_b
                    SET date_renewed = l_date,
					    object_version_number = (object_version_number + 1)
					WHERE id = l_id_tbl(i);

            l_id_tbl.delete;
		END LOOP;
		CLOSE c_old_lines;
        l_id_tbl.delete;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='||x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_old_lines%isopen) THEN
                CLOSE c_old_lines;
            END IF;
            RAISE;

    END UPDATE_SOURCE_CONTRACT;


    /*
    Internal procedure that updates the date_active and date_inactive of the conditions
    associated with the renewed contract
    */

    PROCEDURE UPDATE_CONDITION_HEADERS
    (
     p_chr_id IN NUMBER,
     p_new_start_date IN DATE,
     p_new_end_date IN DATE,
     p_old_start_date IN DATE,
     p_old_end_date IN DATE,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS

    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_CONDITION_HEADERS';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text    VARCHAR2(512);

	cursor c_condition_headers(cp_chr_id in number) is
		select id, date_active, date_inactive
		from okc_condition_headers_b
		where dnz_chr_id = cp_chr_id;

	type cond_rec is record(
		id		        number,
		date_active	    date,
		date_inactive	date);

	TYPE cond_rec_tbl_type IS TABLE OF cond_rec INDEX BY BINARY_INTEGER;

	l_cond_tbl              cond_rec_tbl_type;
	l_id_tbl                num_tbl_type;
	l_date_inactive_tbl     date_tbl_type;

    BEGIN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id='||p_chr_id||' ,p_new_start_date='||p_new_start_date||' ,p_new_end_date='||p_new_end_date||
            ' ,p_old_start_date='||p_old_start_date||' ,p_old_end_date='||p_old_end_date);
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

		open c_condition_headers(p_chr_id);
		loop
			fetch c_condition_headers bulk collect into l_cond_tbl limit G_BULK_FETCH_LIMIT;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.bulk_fetch', 'l_cond_tbl.count='||l_cond_tbl.count);
            END IF;

            exit when (l_cond_tbl.count = 0);

			for i in l_cond_tbl.first..l_cond_tbl.last loop
				l_id_tbl(i) := l_cond_tbl(i).id;
				l_date_inactive_tbl(i) := null;

				if l_cond_tbl(i).date_inactive is not null then
					if (l_cond_tbl(i).date_inactive = p_old_end_date and
						l_cond_tbl(i).date_active = p_old_start_date) then
						l_date_inactive_tbl(i) := p_new_end_date;
					else
						l_date_inactive_tbl(i) := p_new_start_date;
					end if;
				else
					if l_cond_tbl(i).date_active <> p_old_start_date then
						l_date_inactive_tbl(i) := p_new_start_date;
					end if;
				end if;
			end loop;

			forall i in l_id_tbl.first..l_id_tbl.last
				update okc_condition_headers_b set
					date_active = p_new_start_date,
					date_inactive = l_date_inactive_tbl(i),
					object_version_number = (object_version_number +1)
					where id = l_id_tbl(i);

            l_cond_tbl.delete;
			l_id_tbl.delete;
			l_date_inactive_tbl.delete;

		end loop;
		close c_condition_headers;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='||x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_condition_headers%isopen) THEN
                CLOSE c_condition_headers;
            END IF;
            RAISE;

    END UPDATE_CONDITION_HEADERS;

    /*
    Internal procedure for repricing a contract based on the renewal rules specified.
    Updates okc_k_lines_b.price_list_id for 'LST' pricing method
    Calls OKS_REPRICE_PVT.Call_Pricing_API to reprice the contract
    Parameters
        p_chr_id            : id of the contract that need to be repriced
        p_price_method      : Pricing method, 'MAN', 'LST' or 'PCT'
        p_price_list_id     : Price List Id for 'LST'/'PCT' pricing methods
        p_markup_percent    : Markup percent for 'PCT' procing method


    */
    PROCEDURE REPRICE_CONTRACT
    (
     p_chr_id IN NUMBER,
     p_price_method IN VARCHAR2,
     p_price_list_id IN VARCHAR2,
     p_markup_percent IN NUMBER,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'REPRICE_CONTRACT';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);
    l_reprice_rec OKS_REPRICE_PVT.reprice_rec_type;

    CURSOR c_top_lines(cp_chr_id IN NUMBER) IS
        SELECT c.cle_id, sum(nvl(c.price_negotiated,0)), sum(nvl(s.tax_amount,0))
        FROM okc_k_lines_b c, oks_k_lines_b s
        WHERE c.dnz_chr_id = cp_chr_id
        --get only sublines for 1,12,19 (14:no renewal, 46:no sublines)
        AND c.lse_id IN (7,8,9,10,11,35, 13, 25)
        AND s.cle_id = c.id
        GROUP BY c.cle_id;

    l_id_tbl        num_tbl_type;
    l_price_tbl     num_tbl_type;
    l_tax_tbl       num_tbl_type;

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id||' ,p_price_method='||p_price_method||' ,p_price_list_id='||p_price_list_id||' ,p_markup_percent='||p_markup_percent);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_reprice_rec.contract_id := p_chr_id;
        IF (p_price_method = 'MAN') THEN
            l_reprice_rec.price_type := p_price_method;
        ELSIF (p_price_method = 'LST')THEN
            l_reprice_rec.price_type := p_price_method;
            l_reprice_rec.price_list_id := p_price_list_id;
            --update toplines with price list id
            UPDATE okc_k_lines_b
                SET price_list_id = p_price_list_id
                WHERE dnz_chr_id = p_chr_id
                AND cle_id IS NULL;
        ELSIF (p_price_method = 'PCT') THEN
            l_reprice_rec.price_type := p_price_method;
            l_reprice_rec.price_list_id := p_price_list_id;
            l_reprice_rec.markup_percent := p_markup_percent;
        ELSE
            --default to manual if no renewal pricing method specified
            --this would atleast pro-rate the old amounts, if duration has changed
            --this should never happen as this is mandatory at GCD global level
            l_reprice_rec.price_type := 'MAN';
        END IF;


        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.call_pricing_api', 'calling OKS_REPRICE_PVT.call_pricing_api p_reprice_rec.contract_id=' || l_reprice_rec.contract_id ||' ,.price_type='||l_reprice_rec.price_type||
            ' ,.price_list_id='||l_reprice_rec.price_list_id||' ,.markup_percent='||l_reprice_rec.markup_percent);
        END IF;

        OKS_REPRICE_PVT.call_pricing_api(
            p_api_version => 1,
            p_init_msg_list => FND_API.G_FALSE,
            p_reprice_rec => l_reprice_rec,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.call_pricing_api', 'after call to  OKS_REPRICE_PVT.call_pricing_api x_return_status=' || x_return_status);
        END IF;

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;


        --update the topline price_negotiated(OKC) and tax_amount(OKS) columns
        --no need for warranty(14 - cannot be renewed) and subscription (46 - no toplines)
        OPEN c_top_lines(p_chr_id);
        LOOP
            FETCH c_top_lines BULK COLLECT INTO l_id_tbl, l_price_tbl, l_tax_tbl LIMIT G_BULK_FETCH_LIMIT;
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.top_line_loop', 'l_id_tbl.count='|| l_id_tbl.count);
            END IF;

            EXIT WHEN (l_id_tbl.count = 0);

            FORALL i IN l_id_tbl.first..l_id_tbl.last
                UPDATE okc_k_lines_b
                    SET price_negotiated = l_price_tbl(i)
                    WHERE id = l_id_tbl(i);

            FORALL i IN l_id_tbl.first..l_id_tbl.last
                UPDATE oks_k_lines_b
                    SET tax_amount = l_tax_tbl(i)
                    WHERE cle_id = l_id_tbl(i);
        END LOOP;
        CLOSE c_top_lines;
        l_id_tbl.delete;
        l_price_tbl.delete;
        l_tax_tbl.delete;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_header', 'updating okc-oks header etimated_amount and tax_amount');
        END IF;

        --update the header
        UPDATE okc_k_headers_all_b h
            SET h.estimated_amount =
                (SELECT sum(price_negotiated) FROM okc_k_lines_b tl
                 WHERE tl.dnz_chr_id = p_chr_id AND tl.cle_id IS NULL
                 AND tl.lse_id IN (1,12,19,46))
            WHERE h.id = p_chr_id;

        UPDATE oks_k_headers_b h
            SET h.tax_amount =
                (SELECT sum(stl.tax_amount) FROM okc_k_lines_b ctl, oks_k_lines_b stl
                 WHERE ctl.dnz_chr_id = p_chr_id AND ctl.cle_id IS NULL
                 AND ctl.lse_id IN (1,12,19,46) AND stl.cle_id = ctl.id)
            WHERE h.chr_id = p_chr_id;


        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_top_lines%isopen) THEN
                CLOSE c_top_lines;
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_top_lines%isopen) THEN
                CLOSE c_top_lines;
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_top_lines%isopen) THEN
                CLOSE c_top_lines;
            END IF;
            RAISE;
    END REPRICE_CONTRACT;

    /*
    Internal procedure for getting a winning resource from JTF Territories
    Calls JTF_TERR_ASSIGN_PUB.get_winners to get the resource
    Parameters
        p_org_id            : org id of the contract
        p_party_id          : customer or subscriber party id
        x_winning_res_id    : resource id of the winning salesrep
    */
    PROCEDURE GET_SALESREP_FROM_JTF
    (
     p_org_id IN NUMBER,
     p_party_id IN NUMBER,
     x_winning_res_id OUT NOCOPY NUMBER,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'GET_SALESREP_FROM_JTF';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    l_prof_terr_qual    VARCHAR2(30);
    l_party_name        VARCHAR2(360);
    l_country_code      VARCHAR2(360);
    l_state_code        VARCHAR2(360);
    l_counter           NUMBER;
    l_count             NUMBER;

    l_gen_bulk_rec      JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type;
    l_gen_return_rec    JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;

    CURSOR c_vendor_details(cp_org_id IN NUMBER, cp_party_id IN NUMBER) IS
        SELECT hz.party_name, hrl.country, hrl.region_2
        FROM hr_locations hrl, hr_all_organization_units hr, hz_parties hz
        WHERE hrl.location_id = hr.location_id
        AND hr.organization_id = cp_org_id
        AND hz.party_id = cp_party_id;

    CURSOR c_customer_details(cp_party_id IN NUMBER) IS
        SELECT hz.party_name, hzl.country, hzl.state
        FROM   hz_parties hz,  hz_party_sites hzs , hz_locations hzl
        WHERE hz.party_id = cp_party_id
        AND   hzs.party_id = hz.party_id
        AND   hzs.identifying_address_flag = 'Y'
        AND   hzl.location_id = hzs.location_id;

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_org_id=' || p_org_id||' ,p_party_id='||p_party_id);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        l_prof_terr_qual:= nvl(FND_PROFILE.value('OKS_SRC_TERR_QUALFIERS'), 'V');
        IF (l_prof_terr_qual = 'V') THEN
            --get the customer name and vendor country and state
            OPEN c_vendor_details(p_org_id, p_party_id);
            FETCH c_vendor_details INTO l_party_name, l_country_code, l_state_code;
            CLOSE c_vendor_details;
        ELSE
            --get customer name and customer country and satte
            OPEN c_customer_details(p_party_id);
            FETCH c_customer_details INTO l_party_name, l_country_code, l_state_code;
            CLOSE c_customer_details;
        END IF;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_country_state', 'profile:OKS_SRC_TERR_QUALFIERS=' || l_prof_terr_qual||' ,l_party_name='||l_party_name||' ,l_country_code='||l_country_code||' ,l_state_code='||l_state_code);
        END IF;

        l_gen_bulk_rec.trans_object_id.EXTEND;
        l_gen_bulk_rec.trans_detail_object_id.EXTEND;
        l_gen_bulk_rec.SQUAL_CHAR01.EXTEND;
        l_gen_bulk_rec.SQUAL_CHAR04.EXTEND;
        l_gen_bulk_rec.SQUAL_CHAR07.EXTEND;
        l_gen_bulk_rec.SQUAL_NUM01.EXTEND;

        l_gen_bulk_rec.trans_object_id(1) := 100;
        l_gen_bulk_rec.trans_detail_object_id(1) := 1000;
        l_gen_bulk_rec.SQUAL_CHAR01(1) := l_party_name;
        l_gen_bulk_rec.SQUAL_CHAR04(1) := l_state_code;
        l_gen_bulk_rec.SQUAL_CHAR07(1) := l_country_code;
        l_gen_bulk_rec.SQUAL_NUM01(1) := p_party_id;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_winners', 'calling JTF_TERR_ASSIGN_PUB.get_winners, p_use_type=RESOURCE, p_source_id=-1500, p_trans_id=-1501');
        END IF;

        fnd_file.put_line(FND_FILE.LOG,'  ');
        fnd_file.put_line(FND_FILE.LOG,'Calling JTF_TERR_ASSIGN_PUB.get_winners  ');
        fnd_file.put_line(FND_FILE.LOG,' Parameters: ');
        fnd_file.put_line(FND_FILE.LOG,' l_gen_bulk_rec.trans_object_id(1): '||100);
        fnd_file.put_line(FND_FILE.LOG,' l_gen_bulk_rec.trans_detail_object_id(1): '||1000);
        fnd_file.put_line(FND_FILE.LOG,' l_gen_bulk_rec.SQUAL_CHAR01(1): '||l_party_name);
        fnd_file.put_line(FND_FILE.LOG,' l_gen_bulk_rec.SQUAL_CHAR04(1): '||l_state_code);
        fnd_file.put_line(FND_FILE.LOG,' l_gen_bulk_rec.SQUAL_CHAR07(1): '||l_country_code);
        fnd_file.put_line(FND_FILE.LOG,' l_gen_bulk_rec.SQUAL_NUM01(1): '||p_party_id);
        fnd_file.put_line(FND_FILE.LOG,'  ');

        JTF_TERR_ASSIGN_PUB.get_winners
        (p_api_version_number => 1.0,
         p_init_msg_list => FND_API.G_FALSE,
         p_use_type => 'RESOURCE',
         p_source_id =>  - 1500,
         p_trans_id =>  - 1501,
         p_trans_rec => l_gen_bulk_rec,
         p_resource_type => FND_API.G_MISS_CHAR,
         p_role => FND_API.G_MISS_CHAR,
         p_top_level_terr_id => FND_API.G_MISS_NUM,
         p_num_winners => FND_API.G_MISS_NUM,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_winners_rec => l_gen_return_rec );

        fnd_file.put_line(FND_FILE.LOG,'  ');
        fnd_file.put_line(FND_FILE.LOG,'After Calling JTF_TERR_ASSIGN_PUB.get_winners  ');
        fnd_file.put_line(FND_FILE.LOG,'x_return_status :  '||x_return_status);
        fnd_file.put_line(FND_FILE.LOG,'x_msg_count :  '||x_msg_count);
        fnd_file.put_line(FND_FILE.LOG,'x_msg_data :  '||x_msg_data);
        fnd_file.put_line(FND_FILE.LOG,'  ');

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_winners', 'after call to JTF_TERR_ASSIGN_PUB.get_winners, x_return_status='||x_return_status);
        END IF;

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        -- bug 5493685
        l_count := NVL(l_gen_return_rec.resource_id.COUNT,0);
        fnd_file.put_line(FND_FILE.LOG,'Resource Count : '||l_count);
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_winners','l_count : '||l_count);
        END IF;

        IF l_count > 0 THEN
          fnd_file.put_line(FND_FILE.LOG,'l_gen_return_rec.resource_id.FIRST : '||l_gen_return_rec.resource_id.FIRST);
          --set OUT parameter
          x_winning_res_id := l_gen_return_rec.resource_id(l_gen_return_rec.resource_id.FIRST);
          fnd_file.put_line(FND_FILE.LOG,'x_winning_res_id : '||x_winning_res_id);
             IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_winners','x_winning_res_id : '||x_winning_res_id);
             END IF;
        END IF; -- l_count > 0
        -- end added  bug 5493685

        /* Commented for bug 5493685
        l_counter := l_gen_return_rec.trans_object_id.FIRST;
        l_count := 0;

        WHILE (l_counter <= l_gen_return_rec.trans_object_id.LAST) LOOP
            --get the first resource found.
            IF (l_count = 0) THEN
                --set OUT parameter
                x_winning_res_id := l_gen_return_rec.resource_id(l_counter);
            END IF;
            l_counter := l_counter + 1;
            l_count := l_count + 1;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_winners_loop', 'l_counter='||l_counter||' ,l_gen_return_rec.resource_id='||l_gen_return_rec.resource_id(l_counter));
            END IF;

        END LOOP;

        END Commented for bug 5493685 */

        IF l_count = 0 THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_NO_JTF_RESOURCE');
            FND_MESSAGE.set_token('PARTY', l_party_name);
            FND_MESSAGE.set_token('COUNTRY', l_country_code);
            FND_MESSAGE.set_token('STATE', l_state_code);
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.get_winners_error', FALSE);
            END IF;
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;
        END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status||' ,x_winning_res_id='||x_winning_res_id);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_vendor_details%isopen) THEN
                CLOSE c_vendor_details;
            END IF;
            IF (c_customer_details%isopen) THEN
                CLOSE c_customer_details;
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_vendor_details%isopen) THEN
                CLOSE c_vendor_details;
            END IF;
            IF (c_customer_details%isopen) THEN
                CLOSE c_customer_details;
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_vendor_details%isopen) THEN
                CLOSE c_vendor_details;
            END IF;
            IF (c_customer_details%isopen) THEN
                CLOSE c_customer_details;
            END IF;
            RAISE;

    END GET_SALESREP_FROM_JTF;


    /*
    Internal procedure for processing sales credits during renewal.
    Parameters
        p_chr_id            : id of the renewed contract that need to be repriced
    */
    PROCEDURE PROCESS_SALES_CREDIT
    (
     p_chr_id IN NUMBER,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'PROCESS_SALES_CREDIT';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    --gets the contract org id and customer/subscriber party id
    CURSOR c_k_hdr(cp_chr_id IN NUMBER) IS
        SELECT  nvl(a.org_id, a.authoring_org_id), to_number(b.object1_id1)
        FROM    okc_k_headers_all_b a, okc_k_party_roles_b b
        WHERE   a.id = cp_chr_id
        AND     b.rle_code IN ('CUSTOMER', 'SUBSCRIBER')
        AND     b.dnz_chr_id = a.id
        AND     b.cle_id IS NULL;

    --gets the salesrep id from jtf resource id and k org id
    CURSOR c_res_salesrep(cp_res_id IN NUMBER, cp_org_id IN NUMBER) IS
        SELECT salesrep_id
        FROM   jtf_rs_salesreps
        WHERE  resource_id = cp_res_id AND org_id = cp_org_id;

    --same salesrep can be defined for multiple orgs - so check
    CURSOR c_check_org_match(cp_salesrep_id IN NUMBER, cp_org_id IN NUMBER) IS /*bugfix for 6672863 */
        SELECT s.org_id,  v.resource_name
        FROM jtf_rs_salesreps s , jtf_rs_resource_extns_vl v
        WHERE s.resource_id = v.resource_id
          AND s.salesrep_id = cp_salesrep_id
	  AND org_id = cp_org_id;  /*bugfix for 6672863*/

    --gets the org name for the org id
    CURSOR c_get_org_name(cp_org_id IN NUMBER) IS
        SELECT hr.name
        FROM hr_all_organization_units hr
        WHERE hr.organization_id = cp_org_id;


    --gets the contract vendor/merhcant record id, rle_code from okc_k_party_roles_b
    CURSOR c_get_ven_mer_id(cp_chr_id IN NUMBER) IS
        SELECT id, rle_code
        FROM okc_k_party_roles_b
        WHERE dnz_chr_id = cp_chr_id AND cle_id IS NULL
        AND rle_code IN ('VENDOR', 'MERCHANT');

    --gets the cro_code for vendor/merchant contact source based on OKX_SALEPERS
    CURSOR c_get_cro_code(cp_rle_code IN VARCHAR2) IS
        SELECT cro_code
        FROM okc_contact_sources
        WHERE buy_or_sell = 'S' AND rle_code = cp_rle_code
        AND jtot_object_code = 'OKX_SALEPERS'
        AND SYSDATE BETWEEN start_date AND NVL(end_date,SYSDATE + 1) ; -- bug 5938308

    --gets the toplines for creating the sales credit
    CURSOR c_get_top_lines(cp_chr_id IN NUMBER) IS
        SELECT id
        FROM okc_k_lines_b
        WHERE dnz_chr_id = cp_chr_id AND cle_id IS NULL AND lse_id IN (1,12,19,46);

    l_prof_enable_sc        VARCHAR2(30);
    l_prof_rev_type         VARCHAR2(30);
    l_prof_use_jtf          VARCHAR2(30);
    l_prof_rev_type_dist    VARCHAR2(30);

    l_org_id                NUMBER;
    l_party_id              NUMBER;
    l_resource_id           NUMBER;
    l_salesrep_id           NUMBER;
    l_dummy_org_id          NUMBER;

    l_cpl_id                NUMBER;
    l_rle_code              VARCHAR2(30);
    l_cro_code              VARCHAR2(30);
    l_sales_group_id        NUMBER;
    l_ctcv_rec_in           okc_contract_party_pub.ctcv_rec_type;
    l_ctcv_rec_in           okc_contract_party_pub.ctcv_rec_type;
    l_percent               NUMBER;
    l_date                  DATE;
    l_created_by            NUMBER;
    l_login_id              NUMBER;
    l_id_tbl                num_tbl_type;

    l_salesrep_name         jtf_rs_resource_extns_vl.resource_name%TYPE;
    l_org_name              hr_all_organization_units.name%TYPE;
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

	    --can have four values, DRT:Derive for Revenue Type and Retain Other
        --YES:Derive,  NO:Drop,  R:Retain, defaults to R
        l_prof_enable_sc := nvl(FND_PROFILE.value('OKS_ENABLE_SALES_CREDIT'), 'R');

        --lookup for revenue type : Select name , id1 from OKX_SALES_CRED_TYPES_V order by NAME;
        --1:Quota Sales Credit, 2:Non-quota Sales Credit
        l_prof_rev_type := FND_PROFILE.VALUE('OKS_REVENUE_TYPE');

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.profile_options', 'OKS_ENABLE_SALES_CREDIT=' || l_prof_enable_sc||' ,OKS_REVENUE_TYPE='||l_prof_rev_type);
        END IF;

        IF (l_prof_enable_sc = 'R') THEN
            --for R:Retain, do nothing
            IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end_1', 'Profile OKS_ENABLE_SALES_CREDIT=R(Retain), no processing required');
            END IF;
            RETURN;
        ELSIF (l_prof_enable_sc = 'NO') THEN
            --for NO:Drop, delete all existing sales credits and return
            DELETE FROM oks_k_sales_credits
                WHERE chr_id = p_chr_id;
            IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end_2', 'Profile OKS_ENABLE_SALES_CREDIT=NO(Drop), deleted sales credits, no fruther processsing');
            END IF;
            RETURN;
        ELSIF(l_prof_enable_sc = 'YES') THEN
            --for YES:Derive, delete all existing sales credits and derive specified type of sales credit
            IF (l_prof_rev_type IS NULL) THEN
                --without the profile setup we cannot recreate the sales credit
                FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INVD_PROFILE_VALUE');
                FND_MESSAGE.set_token('PROFILE', 'OKS_REVENUE_TYPE');
                IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.message(FND_LOG.level_error, l_mod_name || '.rev_type_chk', FALSE);
                END IF;
                FND_MSG_PUB.add;
                RAISE FND_API.g_exc_error;
            ELSE
                DELETE FROM oks_k_sales_credits
                    WHERE chr_id = p_chr_id;
            END IF;
        ELSIF (l_prof_enable_sc = 'DRT') THEN
            --for DRT:Derive for Revenue Type and Retain Other, delete and derive specified type of sales credit
            IF (l_prof_rev_type IS NULL) THEN
                FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INVD_PROFILE_VALUE');
                FND_MESSAGE.set_token('PROFILE', 'OKS_REVENUE_TYPE');
                IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.message(FND_LOG.level_error, l_mod_name || '.rev_type_chk', FALSE);
                END IF;
                FND_MSG_PUB.add;
                RAISE FND_API.g_exc_error;
            ELSE
                DELETE FROM oks_k_sales_credits
                    WHERE chr_id = p_chr_id AND sales_credit_type_id1 = l_prof_rev_type;
            END IF;
        END IF; --of ELSIF (l_prof_enable_sc = 'DRT') THEN

        --we come here only if l_prof_enable_sc = 'YES' or 'DRT'
        --derive the sales credits for the specified revenue type

        --get the contract org and customer/subscriber party id
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_k_org_party', 'getting contract org and customer/subscriber party for p_chr_id='||p_chr_id);
        END IF;

        OPEN c_k_hdr(p_chr_id);
        FETCH c_k_hdr INTO l_org_id, l_party_id;
        CLOSE c_k_hdr;
        IF (l_org_id IS NULL) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INV_CONTRACT');
            FND_MESSAGE.set_token('CONTRACT_ID', p_chr_id);
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.get_k_org_party', FALSE);
            END IF;
            FND_MSG_PUB.ADD;
            RAISE FND_API.g_exc_error;
        END IF;

        --get the winning salesrep either from JTF or profile option
        l_prof_use_jtf := FND_PROFILE.VALUE('OKS_USE_JTF');

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_k_org_party', 'l_org_id='||l_org_id||' ,l_party_id='||l_party_id||' ,Profile OKS_USE_JTF='||l_prof_use_jtf);
        END IF;

        IF (l_prof_use_jtf = 'YES') THEN
            --get the salesrep from JTF Territory setup
            --note this procedure will throw an error if no salesrep is setup in JTF
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_salesrep', 'calling get_salesrep_from_jtf');
            END IF;

            fnd_file.put_line(FND_FILE.LOG,'Calling get_salesrep_from_jtf');
            get_salesrep_from_jtf(
                p_org_id => l_org_id,
                p_party_id => l_party_id,
                x_winning_res_id => l_resource_id,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_salesrep', 'after call to get_salesrep_from_jtf, x_return_status='||x_return_status||' ,l_resource_id='||l_resource_id);
            END IF;

            --get the salesrep id corresponding to this resource and k org
            OPEN c_res_salesrep(l_resource_id, l_org_id);
            FETCH c_res_salesrep INTO l_salesrep_id;
            CLOSE c_res_salesrep;

            IF l_salesrep_id IS NULL THEN
                FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_NO_SREP_FOR_RES');
                FND_MESSAGE.set_token('RESOURCE_ID', l_resource_id);
                IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.message(FND_LOG.level_error, l_mod_name || '.get_jtf_salesrep', FALSE);
                END IF;
                FND_MSG_PUB.ADD;
                RAISE FND_API.g_exc_error;
            END IF;

        ELSE
            --get the salesrep from profile option
            l_salesrep_id := FND_PROFILE.value('OKS_SALESPERSON_ID');

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_salesrep', 'salesrep from profile option OKS_SALESPERSON_ID='||l_salesrep_id);
            END IF;

            IF l_salesrep_id IS NULL THEN
                FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INVD_PROFILE_VALUE');
                FND_MESSAGE.set_token('PROFILE', 'OKS_SALESPERSON_ID');
                IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.message(FND_LOG.level_error, l_mod_name || '.get_prof_salesrep', FALSE);
                END IF;
                FND_MSG_PUB.add;
                RAISE FND_API.g_exc_error;
            END IF;

        END IF; --of IF (l_prof_use_jtf = 'YES') THEN

        --now check if the salesrep belongs to the same org as the contract
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.org_id_match', 'checking salerep org,  l_salesrep_id='||l_salesrep_id||' ,l_org_id='||l_org_id);
        END IF;

        OPEN c_check_org_match(l_salesrep_id, l_org_id);/*bugfix 6672863*/
        FETCH c_check_org_match INTO l_dummy_org_id, l_salesrep_name;
        CLOSE c_check_org_match;

        IF (nvl(l_dummy_org_id,-99) <> l_org_id) THEN
            --as per bug # 2968069, if salesrep does not belong to the same org as the contract
            --we proceed without creating sales credit or adding the salerep to the contract
            --Note this can only happen for FND_PROFILE.VALUE('OKS_USE_JTF') = NO
            OPEN c_get_org_name(l_org_id);
            FETCH c_get_org_name INTO l_org_name;
            CLOSE c_get_org_name;

            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_SALESREP_ORG_MATCH');
            FND_MESSAGE.set_token('SALESREP_NAME', l_salesrep_name);
            FND_MESSAGE.set_token('ORG_NAME', l_org_name);
            IF (FND_LOG.level_event >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_event, l_mod_name || '.org_id_match', FALSE);
            END IF;
            FND_MSG_PUB.add;
            x_return_status := OKC_API.g_ret_sts_warning;
            RETURN;
        END IF;

        --get the party role id, rle_code for vendor/merchant
        OPEN c_get_ven_mer_id(p_chr_id);
        FETCH c_get_ven_mer_id INTO l_cpl_id, l_rle_code;
        CLOSE c_get_ven_mer_id;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_ven_mer_id', 'vendor/merhant details,  l_cpl_id='||l_cpl_id||' ,l_rle_code='||l_rle_code);
        END IF;

        IF (l_cpl_id IS NULL) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_NO_VENDOR_MERCHANT');
            FND_MESSAGE.set_token('CONTRACT_ID', to_char(p_chr_id));
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.get_ven_mer_id', FALSE);
            END IF;
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;
        END IF;

        --get the first cro_code from vendor/merchant contact sources that are based on the
        --jtf object OKX_SALEPERS. There can be many contact sources based on OKX_SALEPERS, we
        --will just choose the first one
        OPEN c_get_cro_code(l_rle_code);
        FETCH c_get_cro_code INTO l_cro_code;
        CLOSE c_get_cro_code;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_cro_code', 'cro_code for role '||l_rle_code||' ,l_cro_code='||l_cro_code);
        END IF;

        IF (l_cro_code IS NULL) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_NO_K_SRC_FOR_SREP');
            FND_MESSAGE.set_token('RLE_CODE', l_rle_code);
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.get_cro_code', FALSE);
            END IF;
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;
        END IF;

        --get the sales group id for the salesrep
        --function returns -1 for errors
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_sales_group', 'calling jtf_rs_integration_pub.get_default_sales_group, p_salesrep_id='||l_salesrep_id||' ,p_org_id='||l_org_id||' ,p_date='||sysdate);
        END IF;

        l_sales_group_id := JTF_RS_INTEGRATION_PUB.get_default_sales_group(
                                p_salesrep_id => l_salesrep_id,
                                p_org_id => l_org_id,
                                p_date => sysdate);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_sales_group', 'after call to JTF_RS_INTEGRATION_PUB.get_default_sales_group, l_sales_group_id='||l_sales_group_id);
        END IF;

        --just log the fact that no salesgroup was found, no error thrown
        IF (l_sales_group_id = -1) THEN
            IF (FND_LOG.level_event >= FND_LOG.g_current_runtime_level) THEN
                FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_NO_SALES_GROUP');
                FND_MESSAGE.set_token('SALESREP_ID', to_char(l_salesrep_id));
                FND_LOG.message(FND_LOG.level_event, l_mod_name || '.get_sales_group', TRUE);
            END IF;
        END IF;

        --delete any old vendor/merchant contacts based on jtf object OKX_SALEPERS
        DELETE FROM okc_contacts
            WHERE dnz_chr_id = p_chr_id
            AND cpl_id = l_cpl_id
            AND cro_code IN (SELECT cro_code FROM okc_contact_sources
                                WHERE buy_or_sell = 'S' AND rle_code = l_rle_code
                                AND jtot_object_code = 'OKX_SALEPERS');

        --add this salesrep as a contact for vendor/merchant with the cro_code found above
        l_created_by := FND_GLOBAL.USER_ID;
        l_date := sysdate;
        l_login_id := FND_GLOBAL.LOGIN_ID;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.create_contact', 'deleted old contacts, creating new contact for salesrep id='||l_salesrep_id);
        END IF;

        INSERT INTO OKC_CONTACTS(
            id,
            cpl_id,
            cro_code,
            dnz_chr_id,
            object1_id1,
            object1_id2,
            jtot_object1_code,
            object_version_number,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
            sales_group_id)
        VALUES(
            okc_p_util.raw_to_number(sys_guid()),
            l_cpl_id,
            l_cro_code,
            p_chr_id,
            l_salesrep_id,
            '#',
            'OKX_SALEPERS',
            1,
            l_created_by,
            l_date,
            l_created_by,
            l_date,
            l_login_id,
            l_sales_group_id);
        /*cgopinee Bug fix for 6882512*/
	OKC_CTC_PVT.update_contact_stecode(p_chr_id =>p_chr_id,
	            x_return_status=>l_return_status);

        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	   RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        --create sales credit for this salesperson
        l_prof_rev_type_dist := nvl(FND_PROFILE.VALUE('OKS_REVENUE_TYPE_DIST'), '0');
        l_percent := to_number(l_prof_rev_type_dist);

        IF (l_percent < 0 OR l_percent > 100) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INVD_PROFILE_VALUE');
            FND_MESSAGE.set_token('PROFILE', 'OKS_REVENUE_TYPE_DIST');
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.get_rev_type_dist', FALSE);
            END IF;
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;
        END IF;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.hdr_sales_credit', 'creating hdr sales credits with  OKS_REVENUE_TYPE_DIST='||l_prof_rev_type_dist);
        END IF;

        INSERT INTO oks_k_sales_credits(
            id,
            percent,
            chr_id,
            cle_id,
            ctc_id,
            sales_credit_type_id1,
            sales_credit_type_id2,
            object_version_number,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            security_group_id,
            sales_group_id)
        VALUES (
            okc_p_util.raw_to_number(sys_guid()),
            l_percent,
            p_chr_id,
            null,
            l_salesrep_id,
            l_prof_rev_type,
            '#',
            1,
            l_created_by,
            l_date,
            l_created_by,
            l_date,
            null,
            l_sales_group_id);

        OPEN c_get_top_lines(p_chr_id);
        LOOP
            FETCH c_get_top_lines BULK COLLECT INTO l_id_tbl LIMIT G_BULK_FETCH_LIMIT;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.line_sales_credit', 'l_id_tbl.count='||l_id_tbl.count);
            END IF;

            EXIT WHEN (l_id_tbl.count = 0);
            FORALL i in l_id_tbl.first..l_id_tbl.last
                INSERT INTO oks_k_sales_credits(
                    id,
                    percent,
                    chr_id,
                    cle_id,
                    ctc_id,
                    sales_credit_type_id1,
                    sales_credit_type_id2,
                    object_version_number,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    security_group_id,
                    sales_group_id)
                VALUES (
                    okc_p_util.raw_to_number(sys_guid()),
                    l_percent,
                    p_chr_id,
                    l_id_tbl(i),
                    l_salesrep_id,
                    l_prof_rev_type,
                    '#',
                    1,
                    l_created_by,
                    l_date,
                    l_created_by,
                    l_date,
                    null,
                    l_sales_group_id);

        END LOOP;
        CLOSE c_get_top_lines;
        l_id_tbl.delete;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            IF ( c_res_salesrep%isopen ) THEN
                CLOSE c_res_salesrep;
            END IF;
            IF ( c_check_org_match%isopen ) THEN
                CLOSE c_check_org_match;
            END IF;
            IF ( c_get_org_name%isopen ) THEN
                CLOSE c_get_org_name;
            END IF;
            IF ( c_get_ven_mer_id%isopen ) THEN
                CLOSE c_get_ven_mer_id;
            END IF;
            IF ( c_get_cro_code%isopen ) THEN
                CLOSE c_get_cro_code;
            END IF;
            IF ( c_get_top_lines%isopen ) THEN
                CLOSE c_get_top_lines;
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            IF ( c_res_salesrep%isopen ) THEN
                CLOSE c_res_salesrep;
            END IF;
            IF ( c_check_org_match%isopen ) THEN
                CLOSE c_check_org_match;
            END IF;
            IF ( c_get_org_name%isopen ) THEN
                CLOSE c_get_org_name;
            END IF;
            IF ( c_get_ven_mer_id%isopen ) THEN
                CLOSE c_get_ven_mer_id;
            END IF;
            IF ( c_get_cro_code%isopen ) THEN
                CLOSE c_get_cro_code;
            END IF;
            IF ( c_get_top_lines%isopen ) THEN
                CLOSE c_get_top_lines;
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF ( c_res_salesrep%isopen ) THEN
                CLOSE c_res_salesrep;
            END IF;
            IF ( c_check_org_match%isopen ) THEN
                CLOSE c_check_org_match;
            END IF;
            IF ( c_get_org_name%isopen ) THEN
                CLOSE c_get_org_name;
            END IF;
            IF ( c_get_ven_mer_id%isopen ) THEN
                CLOSE c_get_ven_mer_id;
            END IF;
            IF ( c_get_cro_code%isopen ) THEN
                CLOSE c_get_cro_code;
            END IF;
            IF ( c_get_top_lines%isopen ) THEN
                CLOSE c_get_top_lines;
            END IF;
            RAISE;

    END PROCESS_SALES_CREDIT;


    /*
    Internal procedure for recreating coverage and subscription entitities. This can be done
    only after the contract dates have been adjusted
    Parameters
        p_chr_id            : id of the renewed contract
    */
    PROCEDURE RECREATE_COV_SUBSCR
    (
     p_chr_id IN NUMBER,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'RECREATE_COV_SUBSCR';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    l_id_tbl                num_tbl_type;
    l_old_id_tbl            num_tbl_type;
    l_lse_id_tbl            num_tbl_type;

    CURSOR c_subscr_service_lines(cp_chr_id IN NUMBER) IS
        SELECT id, nvl(orig_system_id1, cle_id_renewed) old_id, lse_id
        FROM okc_k_lines_b
        WHERE dnz_chr_id = cp_chr_id AND cle_id IS NULL
        AND lse_id IN (1,19,46);

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OPEN c_subscr_service_lines(p_chr_id);
        LOOP
            FETCH c_subscr_service_lines BULK COLLECT INTO l_id_tbl, l_old_id_tbl, l_lse_id_tbl LIMIT G_BULK_FETCH_LIMIT;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.subcr_service_loop', 'l_id_tbl.count='||l_id_tbl.count);
            END IF;
            EXIT WHEN (l_id_tbl.count = 0);

            FOR i IN l_id_tbl.first..l_id_tbl.last LOOP
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.subcr_service_loop', 'i='||i||' ,l_id_tbl(i)='||l_id_tbl(i)||', l_lse_id_tbl(i)='||l_lse_id_tbl(i)||' ,l_old_id_tbl(i)='||l_old_id_tbl(i));
                END IF;

                --recreate coverage entities
                IF( l_lse_id_tbl(i) IN (1,19) ) THEN

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.copy_coverage', 'calling OKS_COVERAGES_PVT.Copy_Coverage, p_contract_line_id='||l_id_tbl(i));
                    END IF;

                    OKS_COVERAGES_PVT.copy_coverage(
                        p_api_version => 1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
                        p_contract_line_id => l_id_tbl(i));

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.copy_coverage', 'after call to OKS_COVERAGES_PVT.Copy_Coverage, x_return_status='||x_return_status);
                    END IF;

                    IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                    ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                    END IF;

                ELSIF (l_lse_id_tbl(i) = 46) THEN

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.copy_subscr', 'calling OKS_SUBSCRIPTION_PUB.copy_subscription, p_source_cle_id='||l_old_id_tbl(i)||' ,p_target_cle_id='||l_id_tbl(i)||', p_intent=RENEW');
                    END IF;

                    OKS_SUBSCRIPTION_PUB.copy_subscription(
                        p_api_version => 1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data,
                        p_source_cle_id => l_old_id_tbl(i),
                        p_target_cle_id => l_id_tbl(i),
                        p_intent => 'RENEW');

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.copy_subscr', 'after call to OKS_SUBSCRIPTION_PUB.copy_subscription, x_return_status='||x_return_status);
                    END IF;

                    IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                    ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                    END IF;
                END IF; --of elsif ELSIF (l_lse_id_tbl(i) = 46) THEN
            END LOOP; --of FOR i IN l_id_tbl.first..l_id_tbl.last LOOP

        END LOOP; --of top line bulk fetch loop
        CLOSE c_subscr_service_lines;
        l_id_tbl.delete;
        l_old_id_tbl.delete;
        l_lse_id_tbl.delete;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            IF ( c_subscr_service_lines%isopen ) THEN
                CLOSE c_subscr_service_lines;
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            IF ( c_subscr_service_lines%isopen ) THEN
                CLOSE c_subscr_service_lines;
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF ( c_subscr_service_lines%isopen ) THEN
                CLOSE c_subscr_service_lines;
            END IF;
            RAISE;
    END RECREATE_COV_SUBSCR;

    /*
    Internal procedure for copying the usage price locks during renewal. Note: the copy API does not
    copy any usage price locks during copy, only after we have obtained the renewal price list, can we
    copy the usage price locks.
    Parameters
        p_chr_id            : id of the renewed contract
        p_org_id            : org id of the renewed contract
        p_contract_number   : number of the renewed contract

    The logic of copying usage price locks is simple
        1. Get the old line's price list and locked price list id and the new line's price list
        2. If old locked price list id is not null (i.e., old line had a price lock)
           and new price list = old price list
           a. Call QP api to lock price list (with the new contract number)
           b. Update new oks lines with the price lock information (locked price list id
              and locked price list line id)
    */
    PROCEDURE COPY_USAGE_PRICE_LOCKS
    (
     p_chr_id IN NUMBER,
     p_org_id IN NUMBER,
     p_contract_number IN VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'COPY_USAGE_PRICE_LOCKS';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    l_old_lpll_tbl              num_tbl_type;
    l_new_cid_tbl               num_tbl_type;

    l_locked_price_list_id      NUMBER;
    l_locked_price_list_line_id NUMBER;

    l_new_lpl_tbl               num_tbl_type;
    l_new_lpll_tbl              num_tbl_type;
    l_old_break_uom_tbl         chr_tbl_type;

    CURSOR c_get_usage_price_locks(cp_chr_id IN NUMBER) IS
        SELECT olds.locked_price_list_line_id, newc.id, nvl(olds.break_uom, 'X')
        FROM okc_k_lines_b oldc, oks_k_lines_b olds, okc_k_lines_b newc
        WHERE newc.dnz_chr_id = cp_chr_id AND newc.lse_id IN (12, 13)
        AND oldc.id = newc.orig_system_id1 AND olds.cle_id = oldc.id
        AND olds.locked_price_list_id IS NOT NULL
        AND nvl(oldc.price_list_id, -99) = nvl(newc.price_list_id, -98);

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id||' ,p_org_id='||p_org_id||' ,p_contract_number='||p_contract_number);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OPEN c_get_usage_price_locks(p_chr_id);
        LOOP
            FETCH c_get_usage_price_locks BULK COLLECT INTO l_old_lpll_tbl, l_new_cid_tbl, l_old_break_uom_tbl LIMIT G_BULK_FETCH_LIMIT;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.usage_locks_loop', 'l_new_cid_tbl.count='||l_new_cid_tbl.count);
            END IF;
            EXIT WHEN (l_new_cid_tbl.count = 0);

            --lock prices for each usage line
            FOR i IN l_new_cid_tbl.first..l_new_cid_tbl.last LOOP
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'usage_locks_loop', 'i='||i||' ,l_old_lpll_tbl(i)='||l_old_lpll_tbl(i));
                END IF;

                l_locked_price_list_id := null;
                l_locked_price_list_line_id := null;
                l_new_lpl_tbl(i) := null;
                l_new_lpll_tbl(i) := null;

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'usage_locks_loop', 'calling QP_LOCK_PRICELIST_GRP.lock_price, p_source_list_line_id='||l_old_lpll_tbl(i)||' ,p_list_source_code=OKS ,p_orig_system_header_ref='||p_contract_number);
                END IF;

                --no bulk price lock api
                QP_LOCK_PRICELIST_GRP.lock_price(
                    p_source_list_line_id => l_old_lpll_tbl(i),
                    p_list_source_code => 'OKS',
                    p_orig_system_header_ref => p_contract_number,
                    p_org_id => p_org_id,
                    x_locked_price_list_id => l_locked_price_list_id,
                    x_locked_list_line_id => l_locked_price_list_line_id,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'usage_locks_loop', 'after call to QP_LOCK_PRICELIST_GRP.lock_price, x_return_status='||x_return_status||
                    ' ,x_locked_price_list_id='||l_locked_price_list_id||' ,x_locked_list_line_id='||l_locked_price_list_line_id);
                END IF;

                IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                END IF;

                l_new_lpl_tbl(i) := l_locked_price_list_id;
                l_new_lpll_tbl(i) := l_locked_price_list_line_id;
                --we select X if it was null to keep pl/sql table indexes in sync
                IF (l_old_break_uom_tbl(i) = 'X') THEN
                    l_old_break_uom_tbl(i) := null;
                END IF;

            END LOOP; --of FOR i IN l_new_cid_tbl.first..l_new_cid_tbl.last LOOP

            FORALL i IN l_new_cid_tbl.first..l_new_cid_tbl.last
                UPDATE oks_k_lines_b
                    SET locked_price_list_id = l_new_lpl_tbl(i),
                        locked_price_list_line_id = l_new_lpll_tbl(i),
                        break_uom = l_old_break_uom_tbl(i)
                    WHERE cle_id = l_new_cid_tbl(i);

        END LOOP; --of top line bulk fetch loop
        CLOSE c_get_usage_price_locks;
        l_old_lpll_tbl.delete;
        l_new_cid_tbl.delete;
        l_new_lpl_tbl.delete;
        l_new_lpll_tbl.delete;
        l_old_break_uom_tbl.delete;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            IF ( c_get_usage_price_locks%isopen ) THEN
                CLOSE c_get_usage_price_locks;
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            IF ( c_get_usage_price_locks%isopen ) THEN
                CLOSE c_get_usage_price_locks;
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF ( c_get_usage_price_locks%isopen ) THEN
                CLOSE c_get_usage_price_locks;
            END IF;
            RAISE;
    END COPY_USAGE_PRICE_LOCKS;

    /*
    Internal procedure for recreating header billing schedule. Called after the contract line dates
    have been adjusted and the contract has been repriced using the renewal pricing method.
    Parameters
        p_chr_id                : id of the renewed contract
        p_old_chr_id            : id of the source contract
    */
    PROCEDURE RECREATE_HDR_BILLING
    (
     p_chr_id IN NUMBER,
     p_old_chr_id IN NUMBER,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'RECREATE_HDR_BILLING';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    CURSOR c_hdr_strlvl(cp_chr_id NUMBER) IS
        SELECT id, chr_id, cle_id, dnz_chr_id, sequence_no, uom_code, start_date, level_periods,
        uom_per_period, advance_periods, level_amount, invoice_offset_days, interface_offset_days,
        comments, due_arr_yn, amount, lines_detailed_yn
        FROM oks_stream_levels_b
        WHERE chr_id = cp_chr_id;

    TYPE hdr_strlvl_tbl IS TABLE OF c_hdr_strlvl%ROWTYPE INDEX BY BINARY_INTEGER;

    l_hdr_strlvl_tbl    hdr_strlvl_tbl;
    l_sllv_tbl          OKS_SLL_PVT.sllv_tbl_type;
    x_sllv_tbl          OKS_SLL_PVT.sllv_tbl_type;
    l_sll_ctr           NUMBER := 0;

    BEGIN
        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id||' ,p_old_chr_id='||p_old_chr_id);
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OPEN c_hdr_strlvl(p_old_chr_id);
        LOOP
            FETCH c_hdr_strlvl BULK COLLECT INTO l_hdr_strlvl_tbl LIMIT G_BULK_FETCH_LIMIT;
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_hdr_sll', 'l_hdr_strlvl_tbl.count=' || l_hdr_strlvl_tbl.count);
            END IF;
            EXIT WHEN (l_hdr_strlvl_tbl.count = 0);

            FOR i IN l_hdr_strlvl_tbl.first..l_hdr_strlvl_tbl.last LOOP
                l_sll_ctr := l_sll_ctr + 1;
                l_sllv_tbl(l_sll_ctr).id := OKC_API.g_miss_num;
                l_sllv_tbl(l_sll_ctr).chr_id := p_chr_id;
                l_sllv_tbl(l_sll_ctr).cle_id := null;
                l_sllv_tbl(l_sll_ctr).dnz_chr_id := p_chr_id;
                l_sllv_tbl(l_sll_ctr).sequence_no := l_hdr_strlvl_tbl(i).sequence_no;
                l_sllv_tbl(l_sll_ctr).uom_code := l_hdr_strlvl_tbl(i).uom_code;
                l_sllv_tbl(l_sll_ctr).start_date := l_hdr_strlvl_tbl(i).start_date;
                l_sllv_tbl(l_sll_ctr).level_periods := l_hdr_strlvl_tbl(i).level_periods;
                l_sllv_tbl(l_sll_ctr).uom_per_period := l_hdr_strlvl_tbl(i).uom_per_period;
                l_sllv_tbl(l_sll_ctr).advance_periods := l_hdr_strlvl_tbl(i).advance_periods;
                l_sllv_tbl(l_sll_ctr).level_amount := l_hdr_strlvl_tbl(i).level_amount;
                l_sllv_tbl(l_sll_ctr).invoice_offset_days := l_hdr_strlvl_tbl(i).invoice_offset_days;
                l_sllv_tbl(l_sll_ctr).interface_offset_days := l_hdr_strlvl_tbl(i).interface_offset_days;
                l_sllv_tbl(l_sll_ctr).comments := l_hdr_strlvl_tbl(i).comments;
                l_sllv_tbl(l_sll_ctr).due_arr_yn := l_hdr_strlvl_tbl(i).due_arr_yn;
                l_sllv_tbl(l_sll_ctr).amount := l_hdr_strlvl_tbl(i).amount;
                l_sllv_tbl(l_sll_ctr).lines_detailed_yn := l_hdr_strlvl_tbl(i).lines_detailed_yn;
            END LOOP;

        END LOOP; --hdr bulk fetch loop
        CLOSE c_hdr_strlvl;
        l_hdr_strlvl_tbl.delete;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_hdr_sll', 'l_sllv_tbl.count=' || l_sllv_tbl.count);
        END IF;

        IF (l_sllv_tbl.count > 0) THEN

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.create_hdr_sll', 'calling OKS_CONTRACT_SLL_PUB.create_sll');
            END IF;

            OKS_CONTRACT_SLL_PUB.create_sll (
                p_api_version => 1,
                p_init_msg_list => FND_API.G_FALSE,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                p_sllv_tbl => l_sllv_tbl,
                x_sllv_tbl => x_sllv_tbl,
                p_validate_yn => 'N');

            l_sllv_tbl.delete;
            x_sllv_tbl.delete;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.create_hdr_sll', 'after call to OKS_CONTRACT_SLL_PUB.create_sll, x_return_status='||x_return_status);
            END IF;

            IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
            ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
            END IF;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.create_hdr_sll', 'calling OKS_BILL_SCH.create_hdr_schedule');
            END IF;

            OKS_BILL_SCH.create_hdr_schedule(
                p_contract_id => p_chr_id,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.create_hdr_sll', 'after call to  OKS_BILL_SCH.create_hdr_schedule, x_return_status='||x_return_status);
            END IF;

            IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
            ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
            END IF;

        END IF; --of IF (l_sllv_tbl.count > 0) THEN


        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_hdr_strlvl%isopen) THEN
                CLOSE c_hdr_strlvl;
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_hdr_strlvl%isopen) THEN
                CLOSE c_hdr_strlvl;
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_hdr_strlvl%isopen) THEN
                CLOSE c_hdr_strlvl;
            END IF;
            RAISE;
    END RECREATE_HDR_BILLING;


    /*
    Internal procedure for recreating line billing schedule. Called after the contract line dates
    have been adjusted and the contract has been repriced using the renewal pricing method.
    Parameters
        p_chr_id                : id of the renewed contract
        p_old_chr_id            : id of the source contract
    */
    PROCEDURE RECREATE_LINE_BILLING
    (
     p_chr_id IN NUMBER,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'RECREATE_LINE_BILLING';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    CURSOR c_get_top_lines(cp_chr_id IN NUMBER) IS
        SELECT renc.id, renc.inv_rule_id, renc.orig_system_id1, rens.billing_schedule_type,
        nvl(renc.price_negotiated,0) new_line_amt,
        (nvl(oldc.price_negotiated, 0) + nvl(olds.ubt_amount, 0) +
         nvl(olds.credit_amount, 0) + nvl(olds.suppressed_credit, 0) ) old_line_amt
        FROM okc_k_lines_b renc, oks_k_lines_b rens,
            okc_k_lines_b oldc, oks_k_lines_b olds
        WHERE renc.dnz_chr_id = cp_chr_id
        AND renc.cle_id IS NULL AND renc.lse_id IN (1,12,19,46) AND rens.cle_id = renc.id
        AND oldc.id = renc.orig_system_id1
        AND olds.cle_id = renc.orig_system_id1;

    TYPE top_line_tbl IS TABLE OF c_get_top_lines%ROWTYPE INDEX BY BINARY_INTEGER;

    CURSOR c_line_strlvl(cp_cle_id NUMBER) IS
        SELECT id, chr_id, cle_id, dnz_chr_id, sequence_no, uom_code, start_date, end_date,
        level_periods, uom_per_period, advance_periods, level_amount, invoice_offset_days,
        interface_offset_days, comments, due_arr_yn, amount, lines_detailed_yn
        FROM oks_stream_levels_b
        WHERE cle_id = cp_cle_id;

    TYPE line_strlvl_tbl IS TABLE OF c_line_strlvl%ROWTYPE INDEX BY BINARY_INTEGER;

    l_top_line_tbl      top_line_tbl;
    l_line_strlvl_tbl   line_strlvl_tbl;

    l_line_sllv_tbl     OKS_BILL_SCH.streamlvl_tbl;
    l_bil_sch_out_tbl   OKS_BILL_SCH.itembillsch_tbl;
    l_line_sll_ctr      NUMBER := 0;

    BEGIN
        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id);
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OPEN c_get_top_lines(p_chr_id);
        LOOP
            FETCH  c_get_top_lines BULK COLLECT INTO l_top_line_tbl LIMIT G_BULK_FETCH_LIMIT;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_toplines', 'l_top_line_tbl.count=' || l_top_line_tbl.count);
            END IF;

            EXIT WHEN (l_top_line_tbl.count = 0);

            --for each topline and it's sublines recreate the billing schedule
            FOR i IN l_top_line_tbl.first..l_top_line_tbl.last LOOP

                 IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.topline_billing', 'i='||i||
                    ' id='||l_top_line_tbl(i).id||
                    ' ,billing_schedule_type='||l_top_line_tbl(i).billing_schedule_type||
                    ' ,inv_rule_id='||l_top_line_tbl(i).inv_rule_id||
                    ',new_line_amt='||l_top_line_tbl(i).new_line_amt||
                    ',old_line_amt='||l_top_line_tbl(i).old_line_amt);
                END IF;

                --initialize before every top line
                l_line_sll_ctr := 0;
                l_line_sllv_tbl.delete;
                l_line_strlvl_tbl.delete;

                --get the old billing schedule rule for the topline
                OPEN c_line_strlvl(l_top_line_tbl(i).orig_system_id1);
                LOOP
                    FETCH c_line_strlvl BULK COLLECT INTO l_line_strlvl_tbl LIMIT G_BULK_FETCH_LIMIT;

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_topline_sll', 'i='||i||'l_top_line_tbl(i).orig_system_id1='||l_top_line_tbl(i).orig_system_id1||' ,l_line_strlvl_tbl.count=' || l_line_strlvl_tbl.count);
                    END IF;

                    EXIT WHEN (l_line_strlvl_tbl.count = 0);


                    FOR j IN l_line_strlvl_tbl.first..l_line_strlvl_tbl.last LOOP
                        l_line_sll_ctr := l_line_sll_ctr + 1;

                        l_line_sllv_tbl(l_line_sll_ctr).id := FND_API.g_miss_num;
                        l_line_sllv_tbl(l_line_sll_ctr).chr_id := FND_API.g_miss_num;
                        l_line_sllv_tbl(l_line_sll_ctr).cle_id := l_top_line_tbl(i).id;
                        l_line_sllv_tbl(l_line_sll_ctr).dnz_chr_id := p_chr_id;
                        l_line_sllv_tbl(l_line_sll_ctr).sequence_no := l_line_strlvl_tbl(j).sequence_no;
                        l_line_sllv_tbl(l_line_sll_ctr).uom_code := l_line_strlvl_tbl(j).uom_code;
                        l_line_sllv_tbl(l_line_sll_ctr).start_date := l_line_strlvl_tbl(j).start_date;
                        l_line_sllv_tbl(l_line_sll_ctr).end_date := l_line_strlvl_tbl(j).end_date;
                        l_line_sllv_tbl(l_line_sll_ctr).level_periods := l_line_strlvl_tbl(j).level_periods;
                        l_line_sllv_tbl(l_line_sll_ctr).uom_per_period := l_line_strlvl_tbl(j).uom_per_period;
                        l_line_sllv_tbl(l_line_sll_ctr).advance_periods := l_line_strlvl_tbl(j).advance_periods;
                        l_line_sllv_tbl(l_line_sll_ctr).level_amount := l_line_strlvl_tbl(j).level_amount;
                        l_line_sllv_tbl(l_line_sll_ctr).invoice_offset_days := l_line_strlvl_tbl(j).invoice_offset_days;
                        l_line_sllv_tbl(l_line_sll_ctr).interface_offset_days := l_line_strlvl_tbl(j).interface_offset_days;
                        l_line_sllv_tbl(l_line_sll_ctr).comments := l_line_strlvl_tbl(j).comments;
                        l_line_sllv_tbl(l_line_sll_ctr).due_arr_yn := l_line_strlvl_tbl(j).due_arr_yn;
                        l_line_sllv_tbl(l_line_sll_ctr).amount := l_line_strlvl_tbl(j).amount;
                        l_line_sllv_tbl(l_line_sll_ctr).lines_detailed_yn := l_line_strlvl_tbl(j).lines_detailed_yn;

                        --set the comments to 99 if old line amt <> new line amt for E and P
                        --some billing code depends on this
                        IF l_top_line_tbl(i).billing_schedule_type IN ('E', 'P') THEN
                            IF ( l_top_line_tbl(i).old_line_amt <> l_top_line_tbl(i).new_line_amt ) THEN
                                l_line_sllv_tbl(l_line_sll_ctr).comments := '99';
                            ELSE
                                l_line_sllv_tbl(l_line_sll_ctr).comments := NULL;
                            END IF;
                        END IF;

                    END LOOP; --topline sll loopFOR j IN l_line_strlvl_tbl.first..l_line_strlvl_tbl.last LOOP

                END LOOP; --topline sll bulk fecth
                CLOSE c_line_strlvl;
                l_line_strlvl_tbl.delete;

                --call the billing api to create the billing schedule for the topline and it's sublines
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.topline_billing', 'calling OKS_BILL_SCH.create_bill_sch_rules');
                END IF;

                OKS_BILL_SCH.create_bill_sch_rules(
                    p_billing_type => l_top_line_tbl(i).billing_schedule_type,
                    p_sll_tbl => l_line_sllv_tbl,
                    p_invoice_rule_id => l_top_line_tbl(i).inv_rule_id,
                    x_bil_sch_out_tbl => l_bil_sch_out_tbl,
                    x_return_status => x_return_status);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.topline_billing', 'after call to OKS_BILL_SCH.create_bill_sch_rules, x_return_status='||x_return_status);
                END IF;

                l_bil_sch_out_tbl.delete;
                l_line_sllv_tbl.delete;

                IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                END IF;

            END LOOP; --topline loop --FOR i IN l_top_line_tbl.first..l_top_line_tbl.last LOOP

        END LOOP; --topline bulk fetch loop
        CLOSE c_get_top_lines;
        l_top_line_tbl.delete;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_get_top_lines%isopen) THEN
                CLOSE c_get_top_lines;
            END IF;
            IF (c_line_strlvl%isopen) THEN
                CLOSE c_line_strlvl;
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_get_top_lines%isopen) THEN
                CLOSE c_get_top_lines;
            END IF;
            IF (c_line_strlvl%isopen) THEN
                CLOSE c_line_strlvl;
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_get_top_lines%isopen) THEN
                CLOSE c_get_top_lines;
            END IF;
            IF (c_line_strlvl%isopen) THEN
                CLOSE c_line_strlvl;
            END IF;
            RAISE;
    END RECREATE_LINE_BILLING;

    /*
    Internal procedure for recreating header billing schedule. Called after the contract line dates
    have been adjusted and the contract has been repriced using the renewal pricing method.
    Parameters
        p_chr_id                : id of the renewed contract
        p_old_chr_id            : id of the source contract
    */
    PROCEDURE RECREATE_BILLING_FROM_BP
    (
     p_chr_id IN NUMBER,
     p_billing_profile_id IN NUMBER,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'RECREATE_BILLING_FROM_BP';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    CURSOR c_bp_toplines (cp_chr_id IN NUMBER) IS
        SELECT a.id, a.start_date, a.end_date, nvl(b.billing_schedule_type, 'XX'),
        a.lse_id, nvl(b.usage_type, 'XX')
        FROM   okc_k_lines_b a, oks_k_lines_b b
        WHERE  a.dnz_chr_id = cp_chr_id AND a.id = b.cle_id
          AND  a.cle_id IS NULL;

    CURSOR c_chk_accounting_rule(l_id NUMBER) IS
        SELECT RULE_ID
        FROM RA_RULES
        WHERE TYPE IN ('A', 'ACC_DUR')
        AND RULE_ID = l_id;

    CURSOR c_chk_invoice_rule(l_id NUMBER) IS
        SELECT RULE_ID
        FROM RA_RULES
        WHERE  TYPE = 'I'
        AND RULE_ID = l_id;

    l_id_tbl            num_tbl_type;
    l_start_dt_tbl      date_tbl_type;
    l_end_dt_tbl        date_tbl_type;
    l_bsch_typ_tbl      chr_tbl_type;
    l_lse_id_tbl        num_tbl_type;
    l_usage_typ_tbl     chr_tbl_type;

    l_rec               OKS_BILLING_PROFILES_PUB.billing_profile_rec;
    l_sll_tbl_out       OKS_BILLING_PROFILES_PUB.stream_level_tbl;

    l_sll_tbl           OKS_BILL_SCH.streamlvl_tbl;
    l_bil_sch_out_tbl   OKS_BILL_SCH.itembillsch_tbl;

    l_invoice_rule_id   NUMBER;
    l_account_rule_id   NUMBER;
    l_rule_id           NUMBER;
    l_var_usg_typ_flag  BOOLEAN := FALSE;

    BEGIN
        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name, 'begin p_chr_id=' || p_chr_id||' , p_billing_profile_id='||p_billing_profile_id);
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OPEN c_bp_toplines(p_chr_id);
        LOOP

            FETCH c_bp_toplines BULK COLLECT INTO l_id_tbl, l_start_dt_tbl, l_end_dt_tbl, l_bsch_typ_tbl, l_lse_id_tbl, l_usage_typ_tbl LIMIT G_BULK_FETCH_LIMIT;
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name ,'get_toplines : l_id_tbl.count=' || l_id_tbl.count);
            END IF;
            EXIT WHEN (l_id_tbl.count = 0);

            --for each topline
            FOR i IN l_id_tbl.first..l_id_tbl.last LOOP
                l_rec.cle_id := l_id_tbl(i);
                l_rec.chr_id := p_chr_id;
                l_rec.billing_profile_id := p_billing_profile_id;
                l_rec.start_date := l_start_dt_tbl(i);
                l_rec.end_date := l_end_dt_tbl(i);

                IF (l_bsch_typ_tbl(i) = 'XX') THEN
                    l_bsch_typ_tbl(i) := NULL;
                END IF;

                --get the billing profile based sll
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name,'get_tl_bill_sch : i='||i||
                    ' calling OKS_BILLING_PROFILES_PUB.get_billing_schedule, l_rec.cle_id='||l_rec.cle_id||
                    ' ,l_rec.start_date='||l_rec.start_date||' ,l_rec.end_date='||l_rec.end_date);
                END IF;

                OKS_BILLING_PROFILES_PUB.get_billing_schedule(
                    p_api_version => 1.0,
                    p_init_msg_list => FND_API.G_FALSE,
                    p_billing_profile_rec => l_rec,
                    x_sll_tbl_out => l_sll_tbl_out,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name,' get_tl_bill_sch: i='||i||' after call to OKS_BILLING_PROFILES_PUB.get_billing_schedule, x_return_status='||x_return_status||' ,l_sll_tbl_out.count='||l_sll_tbl_out.count);
                END IF;

                IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                END IF;

                --note  OKS_BILLING_PROFILES_PUB.get_billing_schedule always returns
                --one row and the  values for invoice_rule_id/account_rule_id don't change for
                --every line, they are the same for a given billing profile.
                --we can therefore validate and update invoice_rule_id/account_rule_id only once
                IF l_sll_tbl_out.COUNT > 0 THEN

                    FOR j IN l_sll_tbl_out.first..l_sll_tbl_out.last LOOP

                        IF( l_invoice_rule_id IS NULL) THEN
                            l_invoice_rule_id := l_sll_tbl_out(j).invoice_rule_id;
                        END IF;
                        IF (l_account_rule_id IS NULL) THEN
                            l_account_rule_id := l_sll_tbl_out(j).account_rule_id;
                        END IF;

                        l_sll_tbl(j).cle_id := l_sll_tbl_out(j).cle_id;
                        l_sll_tbl(j).dnz_chr_id := p_chr_id;
                        l_sll_tbl(j).sequence_no := l_sll_tbl_out(j).seq_no;
                        l_sll_tbl(j).start_date := l_sll_tbl_out(j).start_date;
                        l_sll_tbl(j).level_periods := l_sll_tbl_out(j).target_quantity;
                        l_sll_tbl(j).uom_per_period := l_sll_tbl_out(j).duration;
                        l_sll_tbl(j).level_amount := l_sll_tbl_out(j).amount;
                        l_sll_tbl(j).invoice_offset_days := l_sll_tbl_out(j).invoice_offset;
                        l_sll_tbl(j).interface_offset_days := l_sll_tbl_out(j).interface_offset;
                        l_sll_tbl(j).uom_code := l_sll_tbl_out(j).timeunit;

                    END LOOP;

                    --create billing schedule for the topline and it's sublines
                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name,'create_tl_bill_sch: i='||i||' calling OKS_BILL_SCH.create_bill_sch_rules');
                    END IF;

                    --for usage lines with variable usage type (Actual by Qty, Actual by Period)
                    --the invoice rule has to be "Arrears" (-3), irrespective of the billing profile value
                    IF ( (l_lse_id_tbl(i) = 12) AND (l_usage_typ_tbl(i) IN ('VRT', 'QTY'))
                         AND (l_invoice_rule_id <> -3) ) THEN

                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'var_usage_chk: i='||i||'  ,l_invoice_rule_id='||l_invoice_rule_id||' ,l_usage_typ_tbl(i)='||l_usage_typ_tbl(i)||' ,id='||l_id_tbl(i));
                        END IF;

                        l_var_usg_typ_flag := TRUE;
                        OKS_BILL_SCH.create_bill_sch_rules(
                            p_billing_type => l_bsch_typ_tbl(i),
                            p_sll_tbl => l_sll_tbl,
                            p_invoice_rule_id => -3,
                            x_bil_sch_out_tbl => l_bil_sch_out_tbl,
                            x_return_status => x_return_status);
                    ELSE
                        OKS_BILL_SCH.create_bill_sch_rules(
                            p_billing_type => l_bsch_typ_tbl(i),
                            p_sll_tbl => l_sll_tbl,
                            p_invoice_rule_id => l_invoice_rule_id,
                            x_bil_sch_out_tbl => l_bil_sch_out_tbl,
                            x_return_status => x_return_status);
                    END IF;

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name, 'create_tl_bill_sch: i='||i||' after call to OKS_BILL_SCH.create_bill_sch_rules, x_return_status='||x_return_status);
                    END IF;

                    IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                    ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                    END IF;

                END IF; --of IF l_sll_tbl_out.COUNT > 0 THEN
                l_sll_tbl_out.delete;
                l_sll_tbl.delete;
                l_bil_sch_out_tbl.delete;

            END LOOP; --of  FOR i IN l_id_tbl.first..l_id_tbl.last LOOP --toplines

        END LOOP; --bulk fetch loop for toplines
        CLOSE c_bp_toplines;
        l_id_tbl.delete;
        l_start_dt_tbl.delete;
        l_end_dt_tbl.delete;
        l_bsch_typ_tbl.delete;

      -- bug 5112991
      -- If there are NO top lines then bypass the below code
      IF l_id_tbl.count <> 0 THEN

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name, 'validate_invoice_rule : l_invoice_rule_id='||l_invoice_rule_id);
        END IF;

        l_rule_id := NULL;
        OPEN c_chk_invoice_rule(l_invoice_rule_id);
        FETCH c_chk_invoice_rule INTO l_rule_id;
        CLOSE c_chk_invoice_rule;

        IF(l_rule_id IS NULL) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INV_INVOICE_RULE');
            FND_MESSAGE.set_token('INVOICE_RULE_ID', l_invoice_rule_id);
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.validate_invoice_rule', FALSE);
            END IF;
            FND_MSG_PUB.ADD;
            RAISE FND_API.g_exc_error;
        END IF;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.validate_accounting_rule', 'l_account_rule_id='||l_account_rule_id);
        END IF;

        l_rule_id := NULL;
        OPEN c_chk_accounting_rule(l_account_rule_id);
        FETCH c_chk_accounting_rule INTO l_rule_id;
        CLOSE c_chk_accounting_rule;

        IF(l_rule_id IS NULL) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INV_ACCTG_RULE');
            FND_MESSAGE.set_token('ACCTG_RULE_ID', l_account_rule_id);
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.validate_accounting_rule', FALSE);
            END IF;
            FND_MSG_PUB.ADD;
            RAISE FND_API.g_exc_error;
        END IF;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'upd_inv_rul : updating invoice rule');
        END IF;
        --update okc_k_lines_b toplines with inv_rule_id
        UPDATE okc_k_lines_b
            SET inv_rule_id = l_invoice_rule_id
            WHERE dnz_chr_id = p_chr_id AND cle_id IS NULL;

        --update variarable usage type lines with "Arrears" (-3) invoice rule if billing profile's invoice
        --rule is different
        IF (l_var_usg_typ_flag) THEN

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name,'upd_inv_rul : updating usage invoice rule');
            END IF;

            UPDATE okc_k_lines_b a
            SET a.inv_rule_id = -3
            WHERE a.dnz_chr_id = p_chr_id AND a.cle_id IS NULL AND a.lse_id = 12
            AND EXISTS (SELECT 1 FROM oks_k_lines_b b
                        WHERE b.cle_id = a.id AND b.usage_type IN ('VRT', 'QTY'));
        END IF;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'upd_acctg_rul : updating accounting rule');
        END IF;
        --update oks_k_lines_b toplines with acct_rule_id
        UPDATE oks_k_lines_b
            SET acct_rule_id = l_account_rule_id
            WHERE cle_id IN (SELECT id FROM okc_k_lines_b
                WHERE dnz_chr_id = p_chr_id AND cle_id IS NULL);

      END IF;-- bug 5112991  l_id_tbl.count <> 0 THEN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name,'end : x_return_status='|| x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_bp_toplines%isopen) THEN
                CLOSE c_bp_toplines;
            END IF;
            IF (c_chk_invoice_rule%isopen) THEN
                CLOSE c_chk_invoice_rule;
            END IF;
            IF (c_chk_accounting_rule%isopen) THEN
                CLOSE c_chk_accounting_rule;
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_bp_toplines%isopen) THEN
                CLOSE c_bp_toplines;
            END IF;
            IF (c_chk_invoice_rule%isopen) THEN
                CLOSE c_chk_invoice_rule;
            END IF;
            IF (c_chk_accounting_rule%isopen) THEN
                CLOSE c_chk_accounting_rule;
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_bp_toplines%isopen) THEN
                CLOSE c_bp_toplines;
            END IF;
            IF (c_chk_invoice_rule%isopen) THEN
                CLOSE c_chk_invoice_rule;
            END IF;
            IF (c_chk_accounting_rule%isopen) THEN
                CLOSE c_chk_accounting_rule;
            END IF;
            RAISE;
    END RECREATE_BILLING_FROM_BP;

    /*
    Internal procedure for recreating the billing schedules. Called after the contract line dates
    have been adjusted and the contract has been repriced using the renewal pricing method.
    Parameters
        p_chr_id                : id of the renewed contract
        p_billing_profile_id    : number of the renewed contract

    The logic of recreating billing is as follows
        1. If renewal rules specify a billing profile
            a. Delete all existing billing schedules
            b. Recreate billing shcedule using the billing profile parameters
        2. If renewed contract duration = old contract duration and no billing profile id specified
            a. Recreate billing schedule using existing rules
        3. If renewed contract duration <> old contract duration and no billing profile specified
            a. Delete all existing billing schedules
            b. Such a contract will later fail QA check, as it will have no billing schedule
    */
    PROCEDURE RECREATE_BILLING
    (
     p_chr_id IN NUMBER,
     p_billing_profile_id IN NUMBER,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'RECREATE_BILLING';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    CURSOR c_hdr_dates(cp_chr_id IN NUMBER) IS
        SELECT ren.start_date, ren.end_date, old.start_date, old.end_date, old.id,
        rens.period_type, rens.period_start, olds.period_type, olds.period_start
        FROM okc_k_headers_all_b ren, okc_k_headers_all_b old,
        oks_k_headers_b rens, oks_k_headers_b olds
        WHERE ren.id = cp_chr_id
        AND rens.chr_id = ren.id
        AND old.id = ren.orig_system_id1
        AND olds.chr_id = old.id;

    l_new_start_date    DATE;
    l_new_end_date      DATE;
    l_old_start_date    DATE;
    l_old_end_date      DATE;
    l_old_chr_id        NUMBER;
    l_new_period_type   oks_k_headers_b.period_type%TYPE;
    l_new_period_start  oks_k_headers_b.period_start%TYPE;
    l_old_period_type   oks_k_headers_b.period_type%TYPE;
    l_old_period_start  oks_k_headers_b.period_start%TYPE;

    l_new_duration      NUMBER;
    l_new_period        VARCHAR2(64);
    l_old_duration      NUMBER;
    l_old_period        VARCHAR2(64);

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id||' ,p_billing_profile_id='||p_billing_profile_id);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OPEN c_hdr_dates(p_chr_id);
        FETCH c_hdr_dates INTO l_new_start_date, l_new_end_date, l_old_start_date, l_old_end_date, l_old_chr_id, l_new_period_type, l_new_period_start, l_old_period_type, l_old_period_start;
        CLOSE c_hdr_dates;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_duration_new', 'calling OKC_TIME_UTIL_PUB.get_duration, l_new_start_date='||l_new_start_date||' ,l_new_end_date='||l_new_end_date);
        END IF;

        OKC_TIME_UTIL_PUB.get_duration(
            p_start_date => l_new_start_date,
            p_end_date => l_new_end_date,
            x_duration => l_new_duration,
            x_timeunit => l_new_period,
            x_return_status => x_return_status);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_duration_new', 'after call to OKC_TIME_UTIL_PUB.get_duration, x_return_status='||x_return_status||' ,l_new_duration='||l_new_duration||' ,l_new_period='||l_new_period);
        END IF;
        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_duration_old', 'calling OKC_TIME_UTIL_PUB.get_duration, l_old_start_date='||l_old_start_date||' ,l_old_end_date='||l_old_end_date);
        END IF;

        OKC_TIME_UTIL_PUB.get_duration(
            p_start_date => l_old_start_date,
            p_end_date => l_old_end_date,
            x_duration => l_old_duration,
            x_timeunit => l_old_period,
            x_return_status => x_return_status);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_duration_old', 'after call to OKC_TIME_UTIL_PUB.get_duration, x_return_status='||x_return_status||' ,l_old_duration='||l_old_duration||' ,l_old_period='||l_old_period);
        END IF;
        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        --delete billing schedules if old duration <> new duration or billing profile specified
        IF((l_old_duration <> l_new_duration) OR (l_old_period <> l_new_period) OR
            (p_billing_profile_id IS  NOT NULL) ) THEN

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_billing', 'p_billing_profile_id='||p_billing_profile_id);
            END IF;

            DELETE FROM oks_level_elements
                WHERE dnz_chr_id = p_chr_id;

            DELETE FROM oks_stream_levels_b
                WHERE dnz_chr_id = p_chr_id;

            --doing this becuase this is what OKS_BILL_SCH.del_rul_elements does
            --and we are replacing that call
            UPDATE oks_k_lines_b
                SET billing_schedule_type = NULL
                WHERE cle_id IN
                    (SELECT id FROM OKC_K_LINES_B WHERE dnz_chr_id = p_chr_id
                    AND lse_id IN (7,8,9,10,11,35,13,18,25));

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.delete_billing', 'done');
            END IF;

        END IF; --of IF((l_old_duration <> l_new_duration....


        --if duration/period match and billing profile is NULL, recreate billing schedule
        IF((l_old_duration = l_new_duration) AND (l_old_period = l_new_period) AND
            (p_billing_profile_id IS NULL) ) THEN

            --for partial periods, the  old period type and start should also match
            --for billing to be recreated
            IF( ( nvl(l_new_period_type, 'X') = nvl(l_old_period_type, 'X') ) AND
                ( nvl(l_new_period_start, 'X') = nvl(l_old_period_start, 'X') ) ) THEN

                --first recreate header billing schedule
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.dur_match_bp_null', 'calling recreate_hdr_billing, p_chr_id='||p_chr_id||' ,p_old_chr_id='||l_old_chr_id);
                END IF;

                recreate_hdr_billing(
                    p_chr_id => p_chr_id,
                    p_old_chr_id => l_old_chr_id,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data,
                    x_return_status => x_return_status);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.dur_match_bp_null', 'after recreate_hdr_billing, x_return_status='||x_return_status);
                END IF;
                --end of contract header billing schedule

                --now recreate lines billing schedule
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.dur_match_bp_null', 'calling recreate_line_billing, p_chr_id='||p_chr_id);
                END IF;

                recreate_line_billing(
                    p_chr_id => p_chr_id,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data,
                    x_return_status => x_return_status);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.dur_match_bp_null', 'after recreate_line_billing, x_return_status='||x_return_status);
                END IF;
                --end of lines billing schedule

            END IF;

        END IF; --of if duration/period matches and billing profile is null


        --if  billing profile specified, recreate billing schedule using billing profile
        IF (p_billing_profile_id IS NOT NULL) THEN

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.bp_not_null', 'calling recreate_billing_from_bp, p_chr_id='||p_chr_id||' ,p_billing_profile_id='||p_billing_profile_id);
            END IF;

            recreate_billing_from_bp(
                p_chr_id => p_chr_id,
                p_billing_profile_id => p_billing_profile_id,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                x_return_status => x_return_status);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.bp_not_null', 'after call to recreate_billing_from_bp, x_return_status='||x_return_status);
            END IF;

        END IF; --IF (p_billing_profile_id IS NOT NULL) THEN


        --If duration/period don't match and billing profile is NULL, no billing schedule
        --is created, such a contract will later fail QA check

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_hdr_dates%isopen) THEN
                CLOSE c_hdr_dates;
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_hdr_dates%isopen) THEN
                CLOSE c_hdr_dates;
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_hdr_dates%isopen) THEN
                CLOSE c_hdr_dates;
            END IF;
            RAISE;

    END RECREATE_BILLING;


    /*
    Internal procedure for assigning a renewed contract to the contract group, if the
    renewed contract does not belong to the group
        p_chr_id                : id of the renewed contract
        p_chr_group_id          : id of the contract group
    */
    PROCEDURE ASSIGN_CONTRACT_GROUP
    (
     p_chr_id IN NUMBER,
     p_chr_group_id IN NUMBER,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'ASSIGN_CONTRACT_GROUP';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    CURSOR c_group_csr(cp_chr_id NUMBER, cp_grp_id IN NUMBER) IS
        SELECT cgp_parent_id id
        FROM   okc_k_grpings
        WHERE  included_chr_id = cp_chr_id
        AND cgp_parent_id = cp_grp_id;

    l_dummy             NUMBER;
    l_cgcv_rec_in       OKC_CONTRACT_GROUP_PUB.cgcv_rec_type;
    l_cgcv_rec_out      OKC_CONTRACT_GROUP_PUB.cgcv_rec_type;

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id||' ,p_chr_group_id='||p_chr_group_id);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --check if contract already belongs to this group
        OPEN c_group_csr(p_chr_id, p_chr_group_id);
        FETCH c_group_csr INTO l_dummy;
        CLOSE c_group_csr;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.chk_k_grp', 'l_dummy='||l_dummy);
        END IF;

        --only assign the contract to the group is it is not a member of that group
        IF (l_dummy IS NULL) THEN

            l_cgcv_rec_in.cgp_parent_id := p_chr_group_id;
            l_cgcv_rec_in.included_chr_id := p_chr_id;
            l_cgcv_rec_in.object_version_number := FND_API.G_MISS_NUM;
            l_cgcv_rec_in.created_by := FND_API.G_MISS_NUM;
            l_cgcv_rec_in.creation_date := FND_API.G_MISS_DATE;
            l_cgcv_rec_in.last_updated_by := FND_API.G_MISS_NUM;
            l_cgcv_rec_in.last_update_date := FND_API.G_MISS_DATE;
            l_cgcv_rec_in.last_update_login := FND_API.G_MISS_NUM;
            l_cgcv_rec_in.included_cgp_id := NULL;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.create_k_grp', 'calling OKC_CONTRACT_GROUP_PVT.create_contract_grpngs');
            END IF;

            OKC_CONTRACT_GROUP_PVT.create_contract_grpngs(
                p_api_version => 1,
                p_init_msg_list => FND_API.G_FALSE,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                p_cgcv_rec => l_cgcv_rec_in,
                x_cgcv_rec => l_cgcv_rec_out);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.create_k_grp', 'after call to OKC_CONTRACT_GROUP_PVT.create_contract_grpngs, x_return_status='||x_return_status);
            END IF;
            IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
            ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
            END IF;

        END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_group_csr%isopen) THEN
                CLOSE c_group_csr;
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_group_csr%isopen) THEN
                CLOSE c_group_csr;
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_group_csr%isopen) THEN
                CLOSE c_group_csr;
            END IF;
            RAISE;

    END ASSIGN_CONTRACT_GROUP;


    /*
    Internal procedure for assigning an approval process to the contract.
        p_chr_id                : id of the renewed contract
        p_chr_group_id          : id of the contract group
    */
    PROCEDURE ASSIGN_CONTRACT_PROCESS
    (
     p_chr_id IN NUMBER,
     p_pdf_id IN NUMBER,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'ASSIGN_CONTRACT_PROCESS';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    CURSOR c_pdf(cp_chr_id NUMBER) IS
        SELECT id, pdf_id
        FROM   okc_k_processes
        WHERE  chr_id = cp_chr_id
        AND pdf_id IN (SELECT id FROM okc_process_defs_b WHERE pdf_type = 'WPS' AND usage = 'APPROVE');

    l_id                NUMBER;
    l_pdf_id            NUMBER;
    l_cpsv_rec_in       OKC_CPS_PVT.cpsv_rec_type;
    l_cpsv_rec_out      OKC_CPS_PVT.cpsv_rec_type;

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id||' ,p_pdf_id='||p_pdf_id);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --check if contract already belongs to this group
        OPEN c_pdf(p_chr_id);
        FETCH c_pdf INTO l_id, l_pdf_id;
        CLOSE c_pdf;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.chk_k_process', 'l_id='||l_id||' ,l_pdf_id='||l_pdf_id);
        END IF;

        IF (l_id IS NULL) THEN

            --no process record exists so, create the contract process with the GCD pdf id
            l_cpsv_rec_in.pdf_id := p_pdf_id;
            l_cpsv_rec_in.chr_id := p_chr_id;
            l_cpsv_rec_in.user_id := FND_GLOBAL.USER_ID;
            l_cpsv_rec_in.in_process_yn := FND_API.G_MISS_CHAR;
            l_cpsv_rec_in.object_version_number := FND_API.G_MISS_NUM;
            l_cpsv_rec_in.created_by := FND_API.G_MISS_NUM;
            l_cpsv_rec_in.creation_date := FND_API.G_MISS_DATE;
            l_cpsv_rec_in.last_updated_by := FND_API.G_MISS_NUM;
            l_cpsv_rec_in.last_update_date := FND_API.G_MISS_DATE;
            l_cpsv_rec_in.last_update_login := FND_API.G_MISS_NUM;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.create_k_process', 'calling OKC_CONTRACT_PVT.create_contract_process');
            END IF;

            OKC_CONTRACT_PVT.create_contract_process(
                p_api_version => 1,
                p_init_msg_list => FND_API.G_FALSE,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                p_cpsv_rec => l_cpsv_rec_in,
                x_cpsv_rec => l_cpsv_rec_out);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.create_k_process', 'after call to OKC_CONTRACT_PVT.create_contract_process, x_return_status='||x_return_status);
            END IF;
            IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
            ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
            END IF;

        ELSE

            IF (l_pdf_id = p_pdf_id) THEN

                --do nothing, as process record exists and has the same pdf as GCD pdf id
                NULL;

            ELSE

                --update the contract process record
                l_cpsv_rec_in.pdf_id := p_pdf_id;
                l_cpsv_rec_in.id := l_id;

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_k_process', 'calling OKC_CONTRACT_PVT.update_contract_process');
                END IF;

                OKC_CONTRACT_PVT.update_contract_process(
                    p_api_version => 1,
                    p_init_msg_list => FND_API.G_FALSE,
                    x_return_status => x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data,
                    p_cpsv_rec => l_cpsv_rec_in,
                    x_cpsv_rec => l_cpsv_rec_out);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_k_process', 'after call to OKC_CONTRACT_PVT.update_contract_process, x_return_status='||x_return_status);
                END IF;
                IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                END IF;

            END IF;
        END IF;


        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_pdf%isopen) THEN
                CLOSE c_pdf;
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_pdf%isopen) THEN
                CLOSE c_pdf;
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_pdf%isopen) THEN
                CLOSE c_pdf;
            END IF;
            RAISE;

    END ASSIGN_CONTRACT_PROCESS;

    /*
    Internal procedure updating various contract header and line attributes as per the renewal rule
        p_chr_id                : id of the renewed contract
        p_rnrl_rec              : effective renewal rules for the renewed contract
        p_notify_to             : salesperson/helpdesk user id on whose behalf the workflow is launched
    */
    PROCEDURE UPDATE_RENEWED_CONTRACT
    (
     p_chr_id IN NUMBER,
     p_rnrl_rec IN OKS_RENEW_UTIL_PVT.rnrl_rec_type,
     p_notify_to IN NUMBER,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_RENEWED_CONTRACT';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    CURSOR c_k_hdr(cp_chr_id IN NUMBER) IS
        SELECT a.contract_number, a.contract_number_modifier,
        nvl(a.org_id, a.authoring_org_id), a.qcl_id, a.estimated_amount, a.currency_code,
        a.payment_term_id, a.conversion_type, a.conversion_rate, a.conversion_rate_date,
        a.conversion_euro_rate, b.renewal_po_number, b.trxn_extension_id,
        b.grace_period, b.grace_duration,  c.date_renewed,  -- added for bug 6086893
        a.start_date, a.end_date, c.scs_code, c.sts_code, c.estimated_amount,
        c.start_date, c.end_date, scs.cls_code, c.id
        FROM okc_k_headers_all_b a, oks_k_headers_b b, okc_k_headers_all_b c, OKC_SUBCLASSES_B SCS
        WHERE a.id = b.chr_id
        AND a.id = cp_chr_id
        AND c.id = a.orig_system_id1
        AND c.scs_code = scs.code;
/*added for bug 9020536*/
   CURSOR Rules_Details(BP_ID NUMBER) IS
     SELECT INVOICE_OBJECT1_ID1,ACCOUNT_OBJECT1_ID1
     FROM oks_billing_profiles_v
     WHERE id=p_rnrl_rec.billing_profile_id;
/*added for bug 9020536*/


-- added for bug 6086893
   l_new_start_date        okc_k_headers_all_b.start_date%TYPE;
   l_new_end_date          okc_k_headers_all_b.end_date%TYPE;
   l_old_scs_code          okc_k_headers_all_b.scs_code%TYPE;
   l_old_sts_code          okc_k_headers_all_b.sts_code%TYPE;
   l_old_estimated_amount  okc_k_headers_all_b.estimated_amount%TYPE;
   l_old_start_date        okc_k_headers_all_b.start_date%TYPE;
   l_old_end_date          okc_k_headers_all_b.end_date%TYPE;
   l_cls_code              okc_subclasses_b.cls_code%TYPE;
   l_old_k_id              okc_k_headers_all_b.id%TYPE;
-- end added for bug 6086893

    l_k_num                     VARCHAR2(120);
    l_k_mod                     VARCHAR2(120);
    l_k_org_id                  NUMBER;
    l_qcl_id                    NUMBER;
    l_estimated_amount          NUMBER;
    l_k_currency_code           VARCHAR2(15);
    l_sob_currency_code         VARCHAR2(15);
    l_payment_term_id           NUMBER;
    l_conv_type                 VARCHAR2(30);
    l_conv_rate                 NUMBER;
    l_conv_rate_date            DATE;
    l_conv_euro_rate            NUMBER;
    --while updating PO number we will just use the first 50 characters, otherwise AR apis fail
    l_renewal_po_number         VARCHAR2(240);
    l_trxn_extension_id         NUMBER;
    l_grace_period              VARCHAR2(30);
    l_grace_duration            NUMBER;
    l_wf_item_key               VARCHAR2(240);
    l_date_renewed              DATE;

    l_cust_po_number            VARCHAR2(50);
    l_cust_po_number_req_yn     VARCHAR2(1);
    l_payment_instruction_type  VARCHAR2(3);
    l_threshold_used            VARCHAR2(1);
    l_renewal_type              VARCHAR2(30);
    l_approval_type             VARCHAR2(30);

    l_est_rev_percent           NUMBER;
    l_est_rev_date              DATE;
    l_renewal_po_used           VARCHAR2(1);
    l_renewal_pricing_type_used VARCHAR2(30);
    l_renewal_markup_percent_used   NUMBER;
    l_renewal_price_list_used   NUMBER;
    l_evn_threshold_amt         NUMBER;
    l_evn_threshold_cur         VARCHAR2(15);
    l_ern_threshold_amt         NUMBER;
    l_ern_threshold_cur         VARCHAR2(15);
    l_renewal_status            VARCHAR2(30);

    l_wf_attributes             OKS_WF_K_PROCESS_PVT.WF_ATTR_DETAILS;

    -- bug 4967105 (base bug 4966475)
    l_est_rev_date_offset  NUMBER;
/*added for bug 9020536*/
    inv_id     NUMBER;
    acct_id    NUMBER;
/*added for bug 9020536*/


    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id);
            OKS_RENEW_UTIL_PVT.log_rules(l_mod_name || '.effective_renewal_rules', p_rnrl_rec);
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OPEN c_k_hdr(p_chr_id);
        FETCH c_k_hdr INTO l_k_num, l_k_mod, l_k_org_id, l_qcl_id, l_estimated_amount,
            l_k_currency_code, l_payment_term_id,
            l_conv_type, l_conv_rate, l_conv_rate_date, l_conv_euro_rate, l_renewal_po_number,
            l_trxn_extension_id, l_grace_period, l_grace_duration,  l_date_renewed,
            -- added bug 6086893
            l_new_start_date, l_new_end_date, l_old_scs_code, l_old_sts_code,
            l_old_estimated_amount, l_old_start_date, l_old_end_date, l_cls_code,l_old_k_id;
            -- end added bug 6086893
        CLOSE c_k_hdr;

        l_qcl_id := nvl(p_rnrl_rec.qcl_id, l_qcl_id);

        --update payment term only if Credit Card is present
        --the check for payment term validity has been moved to Contract QA
        IF (l_trxn_extension_id IS NOT NULL) THEN
            l_payment_term_id := nvl(to_number(p_rnrl_rec.payment_terms_id1), l_payment_term_id);
        END IF;

        --always stamp the renewal po number to customer po number
        l_cust_po_number := substr(l_renewal_po_number, 1, 50);

        --p_rnrl_rec will follow the K->Party->Org->Global path for po required flag, can be null also
        --we need to change the l_cust_po_number_req_yn to N, if renewal type is evergreen
        l_cust_po_number_req_yn := p_rnrl_rec.po_required_yn;

        --as per lookup type OKS_PAYMENT_INST_TYPE
        IF ((l_renewal_po_number IS NOT NULL) OR (nvl(l_cust_po_number_req_yn, 'N') = 'Y') )  THEN
            l_payment_instruction_type := 'PON';
        ELSE
            --we will always null out payment instructions, except when the renewal PO number is stamped
            l_payment_instruction_type := NULL;
        END IF;

        --Null out the CVN (currency conversion) attributes if contract currency = set of books currency
        --for the contract org
        l_sob_currency_code := OKC_CURRENCY_API.get_ou_currency(l_k_org_id);
        IF( l_sob_currency_code = l_k_currency_code) THEN
            l_conv_type := NULL;
            l_conv_rate := NULL;
            l_conv_rate_date := NULL;
            l_conv_euro_rate := NULL;
        END IF;

        --determine the renewal type and corresponding approval type
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.determine_renewal_type', 'calling OKS_RENEW_UTIL_PVT.get_renewal_type');
        END IF;
        OKS_RENEW_UTIL_PVT.get_renewal_type(
            p_api_version => 1,
            p_init_msg_list => FND_API.G_FALSE,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_chr_id => p_chr_id,
            p_amount => l_estimated_amount,
            p_currency_code => l_k_currency_code,
            p_rnrl_rec => p_rnrl_rec,
            x_renewal_type => l_renewal_type,
            x_approval_type => l_approval_type,
            x_threshold_used => l_threshold_used);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.determine_renewal_type', 'after call to OKS_RENEW_UTIL_PVT.get_renewal_type, x_renewal_type='||l_renewal_type||
            ' ,x_approval_type='||l_approval_type||' ,x_threshold_used='||l_threshold_used);
        END IF;

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        --set the po required to N if renewal type is EVN
        IF (l_renewal_type = 'EVN') THEN
            l_cust_po_number_req_yn := 'N';
        END IF;

        -- bug 4967105 (base bug 4966475)
        IF NVL(p_rnrl_rec.revenue_estimated_duration,0) = 0 THEN
	   l_est_rev_date_offset := 0;
	ELSE
	   l_est_rev_date_offset := 1;
	END IF;

        l_est_rev_percent := p_rnrl_rec.revenue_estimated_percent;
        l_est_rev_date := OKC_TIME_UTIL_PUB.get_enddate(
                              p_start_date => trunc(l_date_renewed),
                              p_duration => p_rnrl_rec.revenue_estimated_duration,
                              p_timeunit => p_rnrl_rec.revenue_estimated_period) + l_est_rev_date_offset; --bug 4967105

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_enddate', 'after call to OKC_TIME_UTIL_PUB.get_enddate, l_est_rev_date='||l_est_rev_date);
        END IF;

        l_grace_period  := nvl(p_rnrl_rec.grace_period, l_grace_period);
        l_grace_duration  := nvl(p_rnrl_rec.grace_duration, l_grace_duration);
        l_renewal_po_used := nvl(l_cust_po_number_req_yn, 'N');

        l_renewal_pricing_type_used := p_rnrl_rec.renewal_pricing_type;
        IF (p_rnrl_rec.renewal_pricing_type = 'MAN') THEN
            l_renewal_markup_percent_used := NULL;
            l_renewal_price_list_used := NULL;
        ELSE
            l_renewal_markup_percent_used := p_rnrl_rec.markup_percent;
            l_renewal_price_list_used := p_rnrl_rec.price_list_id1;
        END IF;

        l_evn_threshold_amt := null;
        l_evn_threshold_cur := null;
        l_ern_threshold_amt := null;
        l_ern_threshold_cur := null;

        IF( (l_renewal_type = 'EVN') AND (l_threshold_used = 'Y') ) THEN
            l_evn_threshold_amt := p_rnrl_rec.evergreen_threshold_amt;
            l_evn_threshold_cur := p_rnrl_rec.base_currency;
        END IF;
        IF( (l_renewal_type = 'ERN') AND (l_threshold_used = 'Y') ) THEN
            l_ern_threshold_amt := p_rnrl_rec.threshold_amount;
            l_ern_threshold_cur := p_rnrl_rec.base_currency;
        END IF;

        --update the renewal status also, so that if the workflow is not launched
        --or the background process does not pick it up, K is still disabled
        --from authoring form
        l_renewal_status := 'DRAFT';
        IF (l_renewal_type = 'EVN') THEN
            IF (l_approval_type = 'Y') THEN
                l_renewal_status := 'PENDING_IA';
            ELSIF (l_approval_type = 'N') THEN
                l_renewal_status := 'PEND_ACTIVATION';
            END IF;
        ELSIF (l_renewal_type = 'ERN') THEN
            l_renewal_status := 'PEND_PUBLISH';
        END IF;

        l_wf_item_key := p_chr_id || to_char(SYSDATE, 'YYYYMMDDHH24MISS');

  /*added for bug 9020536 */
       OPEN Rules_Details(p_rnrl_rec.billing_profile_id);
        FETCH Rules_Details INTO inv_id,acct_id;
        CLOSE Rules_Details;
  /*added for bug 9020536 */



        --update oks with the new attributes
        UPDATE oks_k_headers_b
            SET renewal_status = l_renewal_status,
                acct_rule_id   = Nvl(acct_id,acct_rule_id),  --added for bug 9020536
                est_rev_percent = l_est_rev_percent,
                est_rev_date = l_est_rev_date,
                grace_duration = l_grace_duration,
                grace_period = l_grace_period,
                renewal_type_used = l_renewal_type,
                renewal_grace_duration_used = l_grace_duration,
                renewal_grace_period_used = l_grace_period,
                renewal_notification_to = p_notify_to,
                renewal_po_used = l_renewal_po_used,
                renewal_pricing_type_used = l_renewal_pricing_type_used,
                renewal_markup_percent_used = l_renewal_markup_percent_used,
                renewal_price_list_used = l_renewal_price_list_used,
                rev_est_percent_used = p_rnrl_rec.revenue_estimated_percent,
                rev_est_duration_used = p_rnrl_rec.revenue_estimated_duration,
                rev_est_period_used = p_rnrl_rec.revenue_estimated_period,
                billing_profile_used = p_rnrl_rec.billing_profile_id,
                ern_flag_used_yn = NULL, --obsolete column
                evn_threshold_amt = l_evn_threshold_amt,
                evn_threshold_cur = l_evn_threshold_cur,
                ern_threshold_amt = l_ern_threshold_amt,
                ern_threshold_cur = l_ern_threshold_cur,
                electronic_renewal_flag = NULL, --obsolete column
                approval_type_used = l_approval_type,
                wf_item_key = l_wf_item_key
            WHERE chr_id = p_chr_id;

        --update OKC header with the new attributes
        --note that we do not update the renewal type/approval type, we carry forward the old values
        UPDATE okc_k_headers_all_b
            SET qcl_id = l_qcl_id,
                inv_rule_id=Nvl(inv_id,inv_rule_id),  --added for bug 9020536
                payment_term_id = l_payment_term_id,
                cust_po_number = l_cust_po_number,
                cust_po_number_req_yn = l_cust_po_number_req_yn,
                payment_instruction_type = l_payment_instruction_type,
                conversion_type = l_conv_type,
                conversion_rate = l_conv_rate,
                conversion_rate_date = l_conv_rate_date,
                conversion_euro_rate = l_conv_euro_rate
            WHERE id = p_chr_id;

        --null out OKC/OKS top lines payment instruction and po number attributes
        UPDATE okc_k_lines_b
            SET payment_instruction_type = NULL,
                    inv_rule_id=Nvl(inv_id,inv_rule_id)  --added for bug 9020536
            WHERE dnz_chr_id = p_chr_id AND cle_id IS NULL AND lse_id IN (1,12,19,46);

        UPDATE oks_k_lines_b b
            SET b.cust_po_number = NULL,
                b.cust_po_number_req_yn = NULL,
                b.acct_rule_id=Nvl(acct_id,acct_rule_id)  --added for bug 9020536
            WHERE b.dnz_chr_id = p_chr_id
            AND b.cle_id IN (SELECT a.id FROM okc_k_lines_b a
                WHERE a.dnz_chr_id = p_chr_id AND a.cle_id IS NULL AND a.lse_id IN (1,12,19,46));


        --for new contracts the workflow process is started by the OKS TAPI
        --for renewed contract this procedure will start the workflow process
        --for Manual renewal - the workflow will not be deferred so that the users can
        --immediately submit it for approval, for Online and Evergreen renewals the worklfow
        --will be started in the deferred mode to reduce execution time for this api

        l_wf_attributes.contract_id := p_chr_id;
        l_wf_attributes.contract_number := l_k_num;
        l_wf_attributes.contract_modifier := l_k_mod;
        l_wf_attributes.negotiation_status := l_renewal_status;
        l_wf_attributes.item_key := l_wf_item_key;
        l_wf_attributes.irr_flag := l_approval_type;
        l_wf_attributes.process_type := l_renewal_type;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.wfprocess', 'calling  OKS_WF_K_PROCESS_PVT.launch_k_process_wf p_wf_attributes: .contract_id='||p_chr_id||
            ' ,.contract_number='||l_k_num||' ,.contract_modifier='||l_k_mod||' ,.negotiation_status='||l_renewal_status||' ,.item_key='||l_wf_item_key||' ,.irr_flag='||l_approval_type||' ,.process_type='||l_renewal_type);
        END IF;

        OKS_WF_K_PROCESS_PVT.launch_k_process_wf(
            p_api_version => 1.0,
            p_init_msg_list => FND_API.G_FALSE,
            p_wf_attributes => l_wf_attributes,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data) ;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.wfprocess', 'after call to OKS_WF_K_PROCESS_PVT.launch_k_process_wf, x_return_status='||x_return_status);
        END IF;

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

      -- bug 6086893
      -- Added call to OKC_K_RENEW_ASMBLR_PVT.acn_assemble after the workflow is successfully launched

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
           FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.acn_assemble', 'BEFORE call to OKC_K_RENEW_ASMBLR_PVT.acn_assemble , p_k_class='||l_cls_code||' ,p_k_nbr_mod= '||l_k_mod||' ,p_k_number= '||l_k_num);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.acn_assemble','p_k_subclass= '||l_old_scs_code||' ,p_k_status_code= '||l_old_sts_code||' ,p_estimated_amount= '||l_old_estimated_amount);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.acn_assemble','p_new_k_end_date= '||l_new_end_date||' ,p_new_k_id= '||p_chr_id||' ,p_new_k_start_date= '||l_new_start_date||' ,p_original_k_end_date= '||l_old_end_date);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.acn_assemble','p_original_kid= '||l_old_k_id||' ,p_original_k_start_date= '||l_old_start_date);
        END IF;

          OKC_K_RENEW_ASMBLR_PVT.acn_assemble(
           p_api_version           => 1,
           p_init_msg_list         => OKC_API.G_FALSE,
           x_return_status         => x_return_status,
           x_msg_count             => x_msg_count,
           x_msg_data              => x_msg_data,
           p_k_class               => l_cls_code,
           p_k_nbr_mod             => l_k_mod,
           p_k_number              => l_k_num,
           p_k_subclass            => l_old_scs_code,
           p_k_status_code         => l_old_sts_code,
           p_estimated_amount      => l_old_estimated_amount,
           p_new_k_end_date        => l_new_end_date,
           p_new_k_id              => p_chr_id,
           p_new_k_start_date      => l_new_start_date,
           p_original_k_end_date   => l_old_end_date,
           p_original_kid          => l_old_k_id,
           p_original_k_start_date => l_old_start_date);


        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.acn_assemble', 'after call to OKC_K_RENEW_ASMBLR_PVT.acn_assemble , x_return_status='||x_return_status);
        END IF;

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;



      -- end added bug 6086893

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
        END IF;

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error;
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            RAISE;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            RAISE;

        WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_unexp_error ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            RAISE;

    END UPDATE_RENEWED_CONTRACT;


------------------------ End  Internal procedures ----------------------------------

    /*
    R12 procedure that validates if a contract can be renewed
    Parameters
        p_chr_id : contract id of the contract being renewed
        p_date : start date of the renewal, if not passed defaults to end date + 1 of the source contract
        p_validation_level : A - do all checks including warnings, E - do only error checks
        x_rnrl_rec : returns the effective renewal rules for the contract
        x_validation_status : S - Success (OK for renewal), W - Warnings (Ok for renewal)
                             E - Errors (Cannot be renewed)
        x_validation_tbl : Validation error and warning messages

    The following validations are done
    Error Conditions
        1.	Contract is a template.
        2.	Contract status is not in ACTIVE, EXPIRED or SIGNED base statuses.
        3.	Contract end date is not null (perpetual contract).
        4.	Contract has been terminated.
        5.	Contract has been renewed and the renewal has not been cancelled.
        6.	If the user does not update access to the contract
        7.	If all sublines (or subscription top lines) in status ACTIVE, EXPIRED or SIGNED
            have already been renew consolidated.
        8.	The effective renewal type for contract is  'Do not renew'. If the renewal type
            is not defined for the contract, it is derived from Party -> Org -> Global setup
            by calling the get_renew_rules procedure.
        9.  If the contract contains any warranty lines (lse id = 14) it cannot be renewed
            (Currently there is no check for warranty lines, a contract having warranty lines
            can be renewed, but all warranty lines are dropped during copy.)

    Warning Conditions
        1.	Contract has been renewed and the renewal has been cancelled.
            For background (events) renewal this is an error condition.
        2.	All contract sublines and subscription toplines have been terminated or cancelled.
            For background (events) renewal this is an error condition.
        3.	All contract sublines and subscription toplines have an effective line renewal type
            code of DNR. (Effective line renewal type code = nvl(line renewal type code ,
            parent line renewal type code). For background (events) renewal this is an error
            condition.

    This procedure does not stop if any error/warning condition is found, all validations
    are always done
    */
    PROCEDURE VALIDATE_RENEWAL
    (
     p_api_version IN NUMBER DEFAULT 1,
     p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     p_chr_id IN NUMBER,
     p_date IN DATE,
     p_validation_level IN VARCHAR2 DEFAULT G_VALIDATE_ALL,
     x_rnrl_rec OUT NOCOPY OKS_RENEW_UTIL_PVT.rnrl_rec_type,
     x_validation_status OUT NOCOPY VARCHAR2,
     x_validation_tbl OUT NOCOPY validation_tbl_type
    )
    IS

    l_api_name CONSTANT VARCHAR2(30) := 'VALIDATE_RENEWAL';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || g_pkg_name || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    --cursor to get basic contract information
    CURSOR c_k_hdr(cp_chr_id IN NUMBER) IS
        SELECT  a.application_id, a.contract_number, a.contract_number_modifier,
            b.ste_code, b.meaning, a.scs_code, a.template_yn,
            a.date_terminated, a.date_renewed, a.end_date
        FROM okc_k_headers_all_b a, okc_statuses_v b
        WHERE a.id = cp_chr_id AND a.sts_code = b.code;

    --cursor to check if all sublines and subscr toplines have been renew consolidated
    CURSOR c_check_line_rencon(cp_chr_id IN NUMBER) IS
        SELECT kl.id
        FROM okc_k_lines_b kl
        WHERE kl.dnz_chr_id = cp_chr_id AND kl.lse_id IN (7, 8, 9, 10, 11, 13, 25, 35, 46)
            AND kl.id NOT IN(
                             SELECT ol.object_cle_id
                             FROM okc_operation_lines ol, okc_operation_instances oi, okc_class_operations oo
                             WHERE oo.cls_code = 'SERVICE' AND oo.opn_code = 'REN_CON' AND oo.id = oi.cop_id
                             AND ol.oie_id = oi.id AND ol.object_chr_id = cp_chr_id
                             AND ol.subject_chr_id IS NOT NULL
                             AND ol.process_flag = 'P'  AND ol.active_yn = 'Y');

    --cursor to check if a contract has been renewed. If the contract  has been
    --renewed, get the renewed contract's status, number and modifier.
    --we order by active_yn desc, as for cancelled renewed contracts
    --active_yn = 'N'. So we want to get the active renewals (such as entered/signed status etc) first
    CURSOR c_check_hdr_renew (cp_chr_id IN NUMBER) IS
        SELECT k.contract_number, k.contract_number_modifier, st.ste_code
        FROM okc_operation_lines ol, okc_operation_instances oi, okc_class_operations oo,
            okc_statuses_b st, okc_k_headers_all_b k
        WHERE oo.cls_code = 'SERVICE' AND oo.opn_code = 'RENEWAL'
            AND oo.id = oi.cop_id
            AND ol.oie_id = oi.id AND ol.object_chr_id = cp_chr_id
            AND ol.subject_chr_id IS NOT NULL AND ol.object_cle_id IS NULL
            AND ol.subject_cle_id IS NULL
            AND ol.process_flag = 'P' AND ol.subject_chr_id = k.id
            AND k.sts_code = st.code
            ORDER BY ol.active_yn DESC;

    --cursor to check if all sublines and subscr toplines have been cancelled or terminated
    CURSOR c_check_line_term_canc (cp_chr_id IN NUMBER) IS
        SELECT id
        FROM okc_k_lines_b
        WHERE dnz_chr_id = cp_chr_id AND lse_id IN (7, 8, 9, 10, 11, 13, 25, 35, 46)
            AND date_terminated IS  NULL AND date_cancelled IS NULL;

    --cursor to determine if any sublines or toplines exist with an effective renewal type
    --that is not DNR. If a topline has renewal type DNR, none of it's sublines are considered.
    --If topline is not DNR then sublines are checked to see if any exist with renewal type not DNR
    CURSOR c_check_line_dnr (cp_chr_id IN NUMBER) IS
        SELECT a.id
        FROM okc_k_lines_b a, okc_k_lines_b b
        WHERE a.dnz_chr_id = cp_chr_id
        AND b.dnz_chr_id (+)  = cp_chr_id
        AND a.cle_id = b.id (+)
        AND a.lse_id IN (7,8,9,10,11,13,25,35,46)
        AND decode(b.line_renewal_type_code, 'DNR', 'DNR',
                    NULL, nvl(a.line_renewal_type_code, 'FUL'),
                    nvl(a.line_renewal_type_code, b.line_renewal_type_code)) <> 'DNR';

    --cursor to check if the contract contains any warranty lines
    CURSOR c_check_line_warr (cp_chr_id IN NUMBER) IS
        SELECT id
        FROM okc_k_lines_b
        WHERE dnz_chr_id = cp_chr_id AND lse_id = 14;

    --cursor to check id there are any valid sublines and subscr toplines
    --we need to do line level checks only if a valid line exists, other wise we get
    --redundant error messages
    CURSOR c_check_valid_line(cp_chr_id IN NUMBER) IS
        SELECT id
        FROM okc_k_lines_b kl, okc_statuses_b st
        WHERE kl.dnz_chr_id = cp_chr_id AND kl.lse_id IN (7, 8, 9, 10, 11, 13, 25, 35, 46)
        AND kl.sts_code = st.ste_code
        AND st.ste_code IN ('ACTIVE', 'EXPIRED', 'SIGNED', 'CANCELLED', 'TERMINATED');

    l_k_app_id okc_k_headers_b.application_id%TYPE;
    l_k_num okc_k_headers_b.contract_number%TYPE;
    l_k_mod okc_k_headers_b.contract_number_modifier%TYPE;
    l_k_ste_code okc_statuses_b.ste_code%TYPE;
    l_k_ste_meaning okc_statuses_tl.meaning%TYPE;
    l_k_scs_code okc_k_headers_b.scs_code%TYPE;
    l_k_template_yn okc_k_headers_b.template_yn%TYPE;
    l_k_date_terminated okc_k_headers_b.date_terminated%TYPE;
    l_k_date_renewed okc_k_headers_b.date_renewed%TYPE;
    l_k_end_date okc_k_headers_b.end_date%TYPE;
    l_rnrl_rec OKS_RENEW_UTIL_PVT.rnrl_rec_type;

    l_date DATE;
    l_k_num_mod VARCHAR2(250);
    l_msg_count INTEGER := 0;
    l_k_is_renewed BOOLEAN := FALSE;
    l_k_access_level VARCHAR2(1);
    l_k_line_id NUMBER;
    l_k_ren_type oks_k_defaults.renewal_type%TYPE;

    l_renk_num okc_k_headers_b.contract_number%TYPE;
    l_renk_mod okc_k_headers_b.contract_number_modifier%TYPE;
    l_renk_ste_code okc_statuses_b.ste_code%TYPE;
    l_valid_line_exists BOOLEAN := FALSE;
    BEGIN
        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id ||' ,p_date='|| p_date ||' ,p_validation_level='|| p_validation_level);
        END IF;

        --standard api initilization and checks
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_validation_status := G_VALID_STS_SUCCESS;

        --first get the basic contract attributes
        OPEN c_k_hdr(p_chr_id);
        FETCH c_k_hdr INTO l_k_app_id, l_k_num, l_k_mod, l_k_ste_code, l_k_ste_meaning,
        l_k_scs_code, l_k_template_yn, l_k_date_terminated, l_k_date_renewed, l_k_end_date;

        IF (c_k_hdr%notfound) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INV_CONTRACT');
            FND_MESSAGE.set_token('CONTRACT_ID', p_chr_id);
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.get_k_values', FALSE);
            END IF;
            FND_MSG_PUB.ADD;
            CLOSE c_k_hdr;
            RAISE FND_API.g_exc_error;
        END IF;
        CLOSE c_k_hdr;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.after_c_k_hdr', 'l_k_app_id=' || l_k_app_id ||' ,l_k_num='|| l_k_num ||' ,l_k_mod='|| l_k_mod ||' ,l_k_ste_code='|| l_k_ste_code ||' ,l_k_ste_meaning='|| l_k_ste_meaning
            ||', l_k_scs_code='|| l_k_scs_code ||' ,l_k_template_yn='|| l_k_template_yn ||', l_k_date_terminated='|| l_k_date_terminated ||' ,l_k_date_renewed='|| l_k_date_renewed ||' ,l_k_end_date='|| l_k_end_date);
        END IF;

        -- no checks if not service contract
        IF ((nvl(l_k_app_id, - 99) <> 515)
            OR (l_k_scs_code NOT IN ('SERVICE', 'WARRANTY', 'SUBSCRIPTION')) )THEN
            RETURN;
        END IF;

        IF(trim(l_k_mod) IS NULL) THEN
            l_k_num_mod := l_k_num;
        ELSE
            l_k_num_mod := l_k_num || '-' || trim(l_k_mod);
        END IF;

        --error if contract has WARRANTY (lse_id =14) lines
        l_k_line_id := NULL;
        OPEN c_check_line_warr(p_chr_id);
        FETCH c_check_line_warr INTO l_k_line_id;
        CLOSE c_check_line_warr;

        IF (l_k_line_id IS NOT NULL) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_WARRANTY_DNR');
            FND_MESSAGE.set_token('NUMBER', l_k_num_mod);
            l_msg_count := l_msg_count + 1;
            x_validation_tbl(l_msg_count).code := 'OKS_WARRANTY_DNR';
            x_validation_tbl(l_msg_count).message := FND_MESSAGE.get;
            x_validation_status := G_VALID_STS_ERROR;
            --we don't  need to do any more checks if this is a warranty contract
            RETURN;
        END IF;

        --error if contract is template
        IF (nvl(l_k_template_yn, 'X') = 'Y') THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_K_TEMPLATE');
            FND_MESSAGE.set_token('NUMBER', l_k_num_mod);
            l_msg_count := l_msg_count + 1;
            x_validation_tbl(l_msg_count).code := 'OKS_K_TEMPLATE';
            x_validation_tbl(l_msg_count).message := FND_MESSAGE.get;
            x_validation_status := G_VALID_STS_ERROR;
        END IF;

        --error if contract end date is not null
        IF (l_k_end_date IS NULL) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_NO_PERPETUAL');
            FND_MESSAGE.set_token('COMPONENT', l_k_num_mod);
            l_msg_count := l_msg_count + 1;
            x_validation_tbl(l_msg_count).code := 'OKS_NO_PERPETUAL';
            x_validation_tbl(l_msg_count).message := FND_MESSAGE.get;
            x_validation_status := G_VALID_STS_ERROR;
        END IF;

        --if p_date is null, use contract end date + 1 . If contract end date is also null use sysdate
        l_date := trunc(nvl(p_date, nvl(l_k_end_date, SYSDATE - 1) + 1));


        --error if status not in 'ACTIVE', 'EXPIRED' and 'SIGNED'
        IF (l_k_ste_code NOT IN ('ACTIVE', 'EXPIRED', 'SIGNED')) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INVALID_K_STATUS');
            FND_MESSAGE.set_token('STATUS', l_k_ste_meaning);
            l_msg_count := l_msg_count + 1;
            x_validation_tbl(l_msg_count).code := 'OKS_INVALID_K_STATUS';
            x_validation_tbl(l_msg_count).message := FND_MESSAGE.get;
            x_validation_status := G_VALID_STS_ERROR;
        END IF;

        --error if contract has been terminated for a future date
        IF (l_k_date_terminated IS NOT NULL) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_FUTURE_TERMINATED_K');
            FND_MESSAGE.set_token('NUMBER', l_k_num_mod);
            l_msg_count := l_msg_count + 1;
            x_validation_tbl(l_msg_count).code := 'OKS_FUTURE_TERMINATED_K';
            x_validation_tbl(l_msg_count).message := FND_MESSAGE.get;
            x_validation_status := G_VALID_STS_ERROR;
        END IF;

        --check if contract has been renewed
        IF (l_k_date_renewed IS NOT NULL) THEN
            l_k_is_renewed := TRUE;
            --This will be checked later to figure get the status of the renewed contract
            --and set the appropriate message in the validation table.
        END IF;

        --error if user does not have update access for the contract
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calling_get_k_access_level', 'p_chr_id=' || p_chr_id ||', l_k_app_id='|| l_k_app_id ||' ,l_k_scs_code='|| l_k_scs_code);
        END IF;

        l_k_access_level := OKC_UTIL.get_all_k_access_level(p_chr_id, l_k_app_id, l_k_scs_code);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.after_get_k_access_level', 'l_k_access_level=' || l_k_access_level);
        END IF;

        IF (nvl(l_k_access_level, 'X') <> 'U') THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_NO_UPDATE');
            FND_MESSAGE.set_token('CHR', l_k_num_mod);
            l_msg_count := l_msg_count + 1;
            x_validation_tbl(l_msg_count).code := 'OKS_NO_UPDATE';
            x_validation_tbl(l_msg_count).message := FND_MESSAGE.get;
            x_validation_status := G_VALID_STS_ERROR;
        END IF;

        --before doing any line level validations, check if there are valid lines to begin with
        l_k_line_id := NULL;
        OPEN c_check_valid_line(p_chr_id);
        FETCH c_check_valid_line INTO l_k_line_id;
        CLOSE c_check_valid_line;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.after_valid_line_check', 'l_k_line_id=' || l_k_line_id);
        END IF;

        IF ( l_k_line_id IS NULL ) THEN
            l_valid_line_exists := FALSE;
        ELSE
            l_valid_line_exists := TRUE;
        END IF;

        IF (l_valid_line_exists) THEN
            --error if all sublines and subsciption toplines have been renew consolidated
            l_k_line_id := NULL;
            OPEN c_check_line_rencon(p_chr_id);
            FETCH c_check_line_rencon INTO l_k_line_id;
            CLOSE c_check_line_rencon;

            IF (l_k_line_id IS NULL) THEN
                FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_K_RENEW_CONSOLIDATED');
                l_msg_count := l_msg_count + 1;
                x_validation_tbl(l_msg_count).code := 'OKS_K_RENEW_CONSOLIDATED';
                x_validation_tbl(l_msg_count).message := FND_MESSAGE.get;
                x_validation_status := G_VALID_STS_ERROR;
            END IF;
        END IF;

        --error if effective renewal type of contract is DNR
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calling_get_renew_rules', 'p_chr_id=' || p_chr_id ||', p_date='|| l_date);
        END IF;

        OKS_RENEW_UTIL_PVT.get_renew_rules(
                        x_return_status => x_return_status,
                        p_api_version => 1.0,
                        p_init_msg_list => FND_API.G_FALSE,
                        p_chr_id => p_chr_id,
                        p_party_id => NULL,
                        p_org_id => NULL,
                        p_date => l_date,
                        p_rnrl_rec => l_rnrl_rec,
                        x_rnrl_rec => x_rnrl_rec,
                        x_msg_count => x_msg_count,
                        x_msg_data => x_msg_data);

        l_k_ren_type := x_rnrl_rec.renewal_type;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.after_get_renew_rules', 'x_return_status=' || x_return_status ||' ,l_k_ren_type='|| l_k_ren_type);
        END IF;

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        IF (nvl(l_k_ren_type, 'X') = 'DNR') THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_DNR_MSG');
            l_msg_count := l_msg_count + 1;
            x_validation_tbl(l_msg_count).code := 'OKS_DNR_MSG';
            x_validation_tbl(l_msg_count).message := FND_MESSAGE.get;
            x_validation_status := G_VALID_STS_ERROR;
        END IF;


        --error if contract has been renewed and renewed contract is in ENETERED status
        --warning if the renewed contract is CANCELLED. All other statuses are also
        --treated as error conditons
        --We need to do this check only if the contract has been renewed (date_renewed is not null)
        --or if validation_level is 'A'. This is baecause if a contract is renewed and then cancelled
        --the date_renewed on the source contract is nulled out

        IF ((l_k_is_renewed) OR (p_validation_level = G_VALIDATE_ALL) ) THEN

            OPEN c_check_hdr_renew (p_chr_id);
            FETCH c_check_hdr_renew INTO l_renk_num, l_renk_mod, l_renk_ste_code;
            CLOSE c_check_hdr_renew;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.checking_for_renewals', 'l_renk_num=' || l_renk_num ||' ,l_renk_mod='|| l_renk_mod ||' ,l_renk_ste_code='|| l_renk_ste_code);
            END IF;

            --if a renewed contract is found, set error/warning message as per status
            IF (l_renk_num IS NOT NULL) THEN

                IF(trim(l_renk_mod) IS NULL) THEN
                    l_renk_num := l_renk_num;
                ELSE
                    l_renk_num := l_renk_num || '-' || trim(l_renk_mod);
                END IF;

                --renewed contract is CANCELLED - warning
                IF(nvl(l_renk_ste_code, 'X') = 'CANCELLED' )THEN

                    FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_ALREADY_NOT_RENEWED');
                    --FND_MESSAGE.set_token('CHR', l_k_num_mod);
                    l_msg_count := l_msg_count + 1;
                    x_validation_tbl(l_msg_count).code := 'OKS_ALREADY_NOT_RENEWED';
                    x_validation_tbl(l_msg_count).message := FND_MESSAGE.get;
                    IF (x_validation_status <> G_VALID_STS_ERROR) THEN
                        x_validation_status := G_VALID_STS_WARNING;
                    END IF;

                --renewed contract is ENETERED - error
                ELSIF (nvl(l_renk_ste_code, 'X') = 'ENTERED' ) THEN

                    FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_RENCOPY_ENTERED');
                    FND_MESSAGE.set_token('NUMBER', l_k_num_mod);
                    FND_MESSAGE.set_token('RENCOPY', l_renk_num);
                    l_msg_count := l_msg_count + 1;
                    x_validation_tbl(l_msg_count).code := 'OKS_RENCOPY_ENTERED';
                    x_validation_tbl(l_msg_count).message := FND_MESSAGE.get;
                    x_validation_status := G_VALID_STS_ERROR;

                --all other statuses treated as ACTIVE ( ACTIVE/EXPIRED/SIGNED/QA_HOLD etc) -error
                ELSE
                    FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_RENCOPY_APPROVE');
                    FND_MESSAGE.set_token('NUMBER', l_k_num_mod);
                    FND_MESSAGE.set_token('RENCOPY', l_renk_num);
                    l_msg_count := l_msg_count + 1;
                    x_validation_tbl(l_msg_count).code := 'OKS_RENCOPY_APPROVE';
                    x_validation_tbl(l_msg_count).message := FND_MESSAGE.get;
                    x_validation_status := G_VALID_STS_ERROR;

                END IF; --of IF( nvl(l_renk_ste_code, 'X') = 'CANCELLED' )THEN

            END IF; --IF (l_renk_num IS NOT NULL) THEN

        END IF; --of IF ( (l_k_is_renewed) OR (p_validation_level = G_VALIDATE_ALL) ) THEN

        --now do the warning checks if p_validation_level = 'A'
        IF (p_validation_level = G_VALIDATE_ALL) THEN

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.checking_for_warnings', 'begin');
            END IF;

            IF (l_valid_line_exists) THEN

                --warning if all sublines and subscr toplines have been terminated or cancelled
                l_k_line_id := NULL;
                OPEN c_check_line_term_canc(p_chr_id);
                FETCH c_check_line_term_canc INTO l_k_line_id;
                CLOSE c_check_line_term_canc;

                IF (l_k_line_id IS NULL) THEN
                    FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_LINES_SUBLINES_TERMINATED');
                    l_msg_count := l_msg_count + 1;
                    x_validation_tbl(l_msg_count).code := 'OKS_LINES_SUBLINES_TERMINATED';
                    x_validation_tbl(l_msg_count).message := FND_MESSAGE.get;
                    IF (x_validation_status <> G_VALID_STS_ERROR) THEN
                        x_validation_status := G_VALID_STS_WARNING;
                    END IF;
                END IF;

                --warning if all sublines and subscr toplines have effective line renewal type of DNR
                l_k_line_id := NULL;
                OPEN c_check_line_dnr(p_chr_id);
                FETCH c_check_line_dnr INTO l_k_line_id;
                CLOSE c_check_line_dnr;

                IF (l_k_line_id IS NULL) THEN
                    FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_LINES_DNR');
                    l_msg_count := l_msg_count + 1;
                    x_validation_tbl(l_msg_count).code := 'OKS_LINES_DNR';
                    x_validation_tbl(l_msg_count).message := FND_MESSAGE.get;
                    IF (x_validation_status <> G_VALID_STS_ERROR) THEN
                        x_validation_status := G_VALID_STS_WARNING;
                    END IF;
                END IF;

            END IF; --of  IF (l_valid_line_exists) THEN

        END IF; --of IF (p_validation_level = G_VALIDATE_ALL) THEN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            IF (x_validation_tbl.count > 0 ) THEN
                FOR i IN x_validation_tbl.first..x_validation_tbl.last LOOP
                    FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.validation_mesg', 'i=' || i ||' , code='|| x_validation_tbl(i).code ||' ,message='|| x_validation_tbl(i).message);
                END LOOP;
            END IF;
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_validation_status=' || x_validation_status ||', x_return_status='|| x_return_status);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            IF (c_check_line_rencon%isopen) THEN
                CLOSE c_check_line_rencon;
            END IF;
            IF (c_check_hdr_renew%isopen) THEN
                CLOSE c_check_hdr_renew;
            END IF;
            IF (c_check_line_term_canc%isopen) THEN
                CLOSE c_check_line_term_canc;
            END IF;
            IF (c_check_line_dnr%isopen) THEN
                CLOSE c_check_line_dnr;
            END IF;
            IF (c_check_line_warr%isopen) THEN
                CLOSE c_check_line_warr;
            END IF;
            IF (c_check_valid_line%isopen) THEN
                CLOSE c_check_valid_line;
            END IF;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            IF (c_check_line_rencon%isopen) THEN
                CLOSE c_check_line_rencon;
            END IF;
            IF (c_check_hdr_renew%isopen) THEN
                CLOSE c_check_hdr_renew;
            END IF;
            IF (c_check_line_term_canc%isopen) THEN
                CLOSE c_check_line_term_canc;
            END IF;
            IF (c_check_line_dnr%isopen) THEN
                CLOSE c_check_line_dnr;
            END IF;
            IF (c_check_line_warr%isopen) THEN
                CLOSE c_check_line_warr;
            END IF;
            IF (c_check_valid_line%isopen) THEN
                CLOSE c_check_valid_line;
            END IF;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            IF (c_check_line_rencon%isopen) THEN
                CLOSE c_check_line_rencon;
            END IF;
            IF (c_check_hdr_renew%isopen) THEN
                CLOSE c_check_hdr_renew;
            END IF;
            IF (c_check_line_term_canc%isopen) THEN
                CLOSE c_check_line_term_canc;
            END IF;
            IF (c_check_line_dnr%isopen) THEN
                CLOSE c_check_line_dnr;
            END IF;
            IF (c_check_line_warr%isopen) THEN
                CLOSE c_check_line_warr;
            END IF;
            IF (c_check_valid_line%isopen) THEN
                CLOSE c_check_valid_line;
            END IF;

    END VALIDATE_RENEWAL;

    /*
    Procedure for updating  invoice_text col table OKC_K_LINES_TL
    with the current line start date and end date. Called during renewal,
    after line dates are adjusted. Uses bulk calls to get and set the invoice text
    Parameters
        p_chr_id    : id of the contract whose lines need to be updated

       The format of the invoice text is as follows
       topline = SUBSTR(l_item_desc || ':' || p_start_date || ':' || p_end_date, 1, 450);

       subline = SUBSTR(p_topline_item_desc || ':' || l_num_items || ':' || l_item_desc || ':' || p_start_date || ':' || p_end_date, 1, 450);

       bug 4712579 / bug 4992884
       subline for usage (lse_id = 13) is as follows
       subline = SUBSTR(p_topline_item_desc || ':' || l_item_desc || ':' || p_start_date || ':' || p_end_date, 1, 450);

	   get invoice text from previous contract subline truncating the dates at the end
    */

    PROCEDURE UPDATE_INVOICE_TEXT
    (
     p_api_version IN NUMBER DEFAULT 1,
     p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_commit   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     p_chr_id IN NUMBER
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_INVOICE_TEXT';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    TYPE line_rec_type IS RECORD(
        sl_id           NUMBER,
        name            VARCHAR2(4000),
        descr           VARCHAR2(4000),
        num_of_items    NUMBER,
        cle_id          NUMBER,
        lse_id          NUMBER,
        start_date      VARCHAR2(100), --DATE,
        end_date        VARCHAR2(100)); --DATE);
    TYPE line_tbl_type IS TABLE OF line_rec_type INDEX BY BINARY_INTEGER;

    l_line_tbl      line_tbl_type;
    l_inv_txt_tbl   chr_tbl_type;
    l_sl_id_tbl     num_tbl_type;
    l_cle_id_tbl    num_tbl_type;
    l_disp_pref     VARCHAR2(255);

    CURSOR c_get_topline_txt (cp_chr_id IN NUMBER) IS
  	    SELECT
            --kl.lse_id, bk.inventory_item_id id1, bk.organization_id id2 , bk.organization_id inv_org_id,
            sl.id, bt.description name, bk.concatenated_segments description, null,
            null, null, to_char(kl.start_date,'DD-MON-YYYY'), to_char(kl.end_date,'DD-MON-YYYY')
  	    FROM mtl_system_items_b_kfv bk, mtl_system_items_tl bt,
            okc_k_items it, oks_k_lines_b sl, okc_k_lines_b kl
  	    WHERE bk.inventory_item_id = bt.inventory_item_id
        AND bk.organization_id = bt.organization_id
  		AND bt.language = USERENV('LANG')
        AND bk.inventory_item_id = it.object1_id1
        AND bk.organization_id = it.object1_id2
        AND it.cle_id = kl.id
        AND sl.cle_id = kl.id
        AND kl.lse_id IN (1, 12, 14, 19, 46)
        AND kl.cle_id IS NULL
        AND kl.dnz_chr_id = cp_chr_id;


    CURSOR c_get_subline_txt (cp_chr_id IN NUMBER) IS
        SELECT
            --kl.lse_id, iv.id1, iv.id2, iv.inv_org_id,
            sl.id, iv.name, iv.description, it.number_of_items,
            kl.cle_id, kl.lse_id, to_char(kl.START_DATE,'DD-MON-YYYY'), to_char(kl.end_date,'DD-MON-YYYY')
        FROM
        (
                SELECT 'OKX_COVSYST' TYPE, T.SYSTEM_ID ID1, '#' ID2, T.NAME NAME,
                T.DESCRIPTION DESCRIPTION, NULL INV_ORG_ID
                FROM CSI_SYSTEMS_TL T
                WHERE T.LANGUAGE = USERENV('LANG')
            UNION ALL
                SELECT 'OKX_PARTYSITE' TYPE, PSE.PARTY_SITE_ID ID1, '#' ID2, PSE.PARTY_SITE_NAME NAME,
                SUBSTR(arp_addr_label_pkg.format_address(NULL,LCN.ADDRESS1,LCN.ADDRESS2,LCN.ADDRESS3,
                LCN.ADDRESS4,LCN.CITY,LCN.COUNTY,LCN.STATE,LCN.PROVINCE,LCN.POSTAL_CODE,NULL,LCN.COUNTRY,
                NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N','N',80,1,1
                ),1,80) DESCRIPTION, NULL INV_ORG_ID
                FROM HZ_PARTY_SITES PSE,HZ_LOCATIONS LCN
                WHERE LCN.LOCATION_ID = PSE.LOCATION_ID
                AND LCN.CONTENT_SOURCE_TYPE = 'USER_ENTERED'
            UNION ALL
                SELECT 'OKX_PARTY' TYPE, P.PARTY_ID ID1, '#' ID2, P.PARTY_NAME NAME,
                P.PARTY_NUMBER DESCRIPTION, NULL INV_ORG_ID
                FROM HZ_PARTIES P
                WHERE P.PARTY_TYPE IN ( 'PERSON','ORGANIZATION')
            UNION ALL
                SELECT 'OKX_CUSTPROD' TYPE, CII.INSTANCE_ID ID1, '#' ID2, SIT.DESCRIPTION NAME,
                BK.CONCATENATED_SEGMENTS DESCRIPTION, BK.ORGANIZATION_ID INV_ORG_ID
                FROM CSI_ITEM_INSTANCES CII, CSI_I_PARTIES CIP,
                MTL_SYSTEM_ITEMS_B_KFV BK, MTL_SYSTEM_ITEMS_TL SIT
                WHERE CII.INSTANCE_ID = CIP.INSTANCE_ID AND CIP.RELATIONSHIP_TYPE_CODE = 'OWNER'
                AND CIP.PARTY_SOURCE_TABLE = 'HZ_PARTIES' AND
                NOT EXISTS ( SELECT 1 FROM CSI_INSTALL_PARAMETERS CIPM
                            WHERE CIPM.INTERNAL_PARTY_ID = CIP.PARTY_ID )
                AND BK.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                AND SIT.INVENTORY_ITEM_ID = BK.INVENTORY_ITEM_ID
                AND SIT.ORGANIZATION_ID = BK.ORGANIZATION_ID
                AND SIT.LANGUAGE = USERENV('LANG')
            UNION ALL
                SELECT  'OKX_CUSTACCT' TYPE, CA.CUST_ACCOUNT_ID ID1, '#' ID2,
                decode(CA.ACCOUNT_NAME, null, 	P.PARTY_NAME, CA.Account_NAME) NAME,
                CA.ACCOUNT_NUMBER DESCRIPTION, NULL INV_ORG_ID
                FROM HZ_CUST_ACCOUNTS CA,HZ_PARTIES P
                WHERE CA.PARTY_ID = P.PARTY_ID
            UNION ALL
                SELECT 'OKX_COUNTER' TYPE, CCT.COUNTER_ID ID1, '#' ID2, CCT.NAME NAME,
                CCT.DESCRIPTION DESCRIPTION, NULL INV_ORG_ID
                FROM CSI_COUNTERS_TL CCT WHERE CCT.LANGUAGE = USERENV('LANG')
            UNION ALL
                SELECT 'OKX_COVITEM' TYPE, B.INVENTORY_ITEM_ID ID1, to_char(B.ORGANIZATION_ID) ID2,
                T.DESCRIPTION NAME, B.CONCATENATED_SEGMENTS DESCRIPTION, B.ORGANIZATION_ID INV_ORG_ID
                FROM MTL_SYSTEM_ITEMS_B_KFV B,MTL_SYSTEM_ITEMS_TL T
                WHERE B.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID AND B.ORGANIZATION_ID = T.ORGANIZATION_ID
                AND T.LANGUAGE = USERENV('LANG')
        ) iv, okc_k_items it, oks_k_lines_b sl, okc_k_lines_b kl, okc_k_headers_all_b kh
        WHERE iv.type = it.jtot_object1_code -- bug 5218936
        AND iv.id1 = it.object1_id1
        AND iv.id2 = it.object1_id2
        AND decode(iv.inv_org_id, null, kh.inv_organization_id, iv.inv_org_id) = kh.inv_organization_id
        AND it.cle_id = kl.id
        AND sl.cle_id = kl.id
        AND kl.lse_id IN (7,8,9,10,11,35, 13, 18, 25)
        AND kl.dnz_chr_id = kh.id
        AND kh.id = cp_chr_id;

 -- bug 4992884 , invoice text for counters lse_id = 13
CURSOR csr_counter_inv_text (cp_chr_id IN NUMBER, cp_sl_id IN NUMBER) IS
SELECT it.concatenated_segments AS Name ,
       it.Description AS Description
 FROM csi_counters_b ccb ,
      csi_counters_tl cct ,
      cs_csi_counter_groups cg ,
      csi_counter_associations cca ,
      csi_item_instances cp ,
      mtl_system_items_kfv it,
      okc_k_items items,
      oks_k_lines_b kl,
      okc_k_headers_all_b khr
WHERE ccb.counter_id = cct.counter_id
  AND cct.language = USERENV('LANG')
  AND ccb.group_id = cg.counter_group_id
  AND ccb.counter_id = cca.counter_id
  AND cca.source_object_code = 'CP'
  AND cca.source_object_id = cp.instance_id
  AND cp.inventory_item_id = it.inventory_item_id
  AND ccb.counter_id = items.object1_id1
  AND items.dnz_chr_id = khr.id
  AND it.organization_id = khr.inv_organization_id
  AND kl.cle_id = items.cle_id
  AND khr.id = cp_chr_id
  AND kl.id = cp_sl_id;

l_counter_inv_text_rec csr_counter_inv_text%ROWTYPE;



    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_procedure, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id);
            END IF;
        END IF;

        --standard api initilization and checks
        SAVEPOINT update_invoice_text_PVT;
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --we will first get and update the topline invoice text
        OPEN c_get_topline_txt(p_chr_id);
        LOOP
            FETCH c_get_topline_txt BULK COLLECT INTO l_line_tbl LIMIT G_BULK_FETCH_LIMIT;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_top_lines', 'l_line_tbl.count='||l_line_tbl.count);
            END IF;

            EXIT WHEN (l_line_tbl.count = 0);

            FOR i in l_line_tbl.first..l_line_tbl.last LOOP
                l_sl_id_tbl(i) :=  l_line_tbl(i).sl_id;
                l_inv_txt_tbl(i) := SUBSTR(l_line_tbl(i).name || ':' || l_line_tbl(i).start_date || ':' || l_line_tbl(i).end_date, 1, 450);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_top_lines_loop', 'i='||i||' ,l_line_tbl(i).name='||l_line_tbl(i).name
                    ||' ,l_line_tbl(i).start_date='||l_line_tbl(i).start_date||' ,l_line_tbl(i).end_date='||l_line_tbl(i).end_date);
                END IF;

            END LOOP;

            --update the oks_k_lines_tl for the toplines
            FORALL j in l_sl_id_tbl.first..l_sl_id_tbl.last
                UPDATE oks_k_lines_tl
                    SET invoice_text = l_inv_txt_tbl(j)
                    WHERE id = l_sl_id_tbl(j) AND language = USERENV('LANG');

            l_line_tbl.delete;
            l_inv_txt_tbl.delete;
            l_sl_id_tbl.delete;

        END LOOP; --topline bulk fetch loop
        CLOSE c_get_topline_txt;
        l_line_tbl.delete;
        l_inv_txt_tbl.delete;
        l_sl_id_tbl.delete;

        --now update the subline invoice text, this requires the top line item desc
        l_disp_pref := fnd_profile.VALUE('OKS_ITEM_DISPLAY_PREFERENCE');
        OPEN c_get_subline_txt(p_chr_id);
        LOOP
            FETCH c_get_subline_txt BULK COLLECT INTO l_line_tbl LIMIT G_BULK_FETCH_LIMIT;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_sub_lines', 'l_line_tbl.count='||l_line_tbl.count);
            END IF;

            EXIT WHEN (l_line_tbl.count = 0);

            FOR i in l_line_tbl.first..l_line_tbl.last LOOP
                l_sl_id_tbl(i) :=  l_line_tbl(i).sl_id;
                l_cle_id_tbl(i) := l_line_tbl(i).cle_id;

                --discuss with Ramesh
                --7,8,9,10,11,35,13,18,25
                --9,18,25(auth),  8,10,11,35(renew), (7,13???)
                --IF (l_line_tbl(i).lse_id IN (8, 10, 11, 35)) THEN

                IF (l_line_tbl(i).lse_id = 13) THEN
                  -- bug 4992884
                  OPEN csr_counter_inv_text (cp_chr_id => p_chr_id, cp_sl_id => l_line_tbl(i).sl_id);
                    FETCH csr_counter_inv_text INTO l_counter_inv_text_rec;
                  CLOSE csr_counter_inv_text;
                    IF ( nvl(l_disp_pref, 'X') = 'DISPLAY_DESC') THEN
                       l_inv_txt_tbl(i) := SUBSTR(l_line_tbl(i).num_of_items || ':' || l_counter_inv_text_rec.name|| ':'|| l_line_tbl(i).start_date || ':' || l_line_tbl(i).end_date, 1, 450);
					ELSE
					   l_inv_txt_tbl(i) := SUBSTR(l_line_tbl(i).num_of_items || ':' || l_counter_inv_text_rec.description|| ':'|| l_line_tbl(i).start_date || ':' || l_line_tbl(i).end_date, 1, 450);
					END IF;
                ELSIF (l_line_tbl(i).lse_id NOT IN (9,18,25)) THEN
                   l_inv_txt_tbl(i) := SUBSTR(l_line_tbl(i).num_of_items || ':' || l_line_tbl(i).descr|| ':'|| l_line_tbl(i).start_date || ':' || l_line_tbl(i).end_date, 1, 450);
                ELSE
                   IF ( nvl(l_disp_pref, 'X') = 'DISPLAY_DESC') THEN
                        l_inv_txt_tbl(i) := SUBSTR(l_line_tbl(i).num_of_items || ':' || l_line_tbl(i).name|| ':'|| l_line_tbl(i).start_date || ':' || l_line_tbl(i).end_date, 1, 450);
                    ELSE
                        l_inv_txt_tbl(i) := SUBSTR(l_line_tbl(i).num_of_items || ':' || l_line_tbl(i).descr|| ':'|| l_line_tbl(i).start_date || ':' || l_line_tbl(i).end_date, 1, 450);
                    END IF;
                END IF;

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_sub_lines_loop', 'i='||i||' ,l_line_tbl(i).name='||l_line_tbl(i).name||' ,l_line_tbl(i).descr='||l_line_tbl(i).descr||
                    ' ,l_line_tbl(i).num_of_items='||l_line_tbl(i).num_of_items||' ,l_line_tbl(i).start_date='||l_line_tbl(i).start_date||' ,l_line_tbl(i).end_date='||l_line_tbl(i).end_date);
                END IF;

            END LOOP;

            --update the oks_k_lines_tl for the sublines using toplines inv txt
            FORALL j in l_sl_id_tbl.first..l_sl_id_tbl.last
                UPDATE oks_k_lines_tl c
                    SET c.invoice_text =
                        (SELECT SUBSTR(a.invoice_text,1, decode(INSTR(a.invoice_text, ':'),0,
                        LENGTH(a.invoice_text), INSTR(a.invoice_text, ':'))) ||l_inv_txt_tbl(j)
                        FROM oks_k_lines_tl a, oks_k_lines_b b
                        WHERE a.id = b.id AND a.language = USERENV('LANG')
                        AND b.cle_id = l_cle_id_tbl(j))
                    WHERE id = l_sl_id_tbl(j) AND language = USERENV('LANG');
            l_line_tbl.delete;
            l_inv_txt_tbl.delete;
            l_sl_id_tbl.delete;
            l_cle_id_tbl.delete;
        END LOOP; --topline bulk fetch loop
        CLOSE c_get_subline_txt;
        l_line_tbl.delete;
        l_inv_txt_tbl.delete;
        l_sl_id_tbl.delete;
        l_cle_id_tbl.delete;

        --standard check of p_commit
	    IF FND_API.to_boolean( p_commit ) THEN
		    COMMIT;
	    END IF;
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_procedure, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
            END IF;
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            ROLLBACK TO update_invoice_text_PVT;
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.g_exc_unexpected_error THEN
            ROLLBACK TO update_invoice_text_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            ROLLBACK TO update_invoice_text_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    END UPDATE_INVOICE_TEXT;

    /*
    Procedure for getting the user id and name of the contact on whose behalf the
    contract workflow is launched during renewal
    Parameters
        p_chr_id            : id of the contract for which the workflow is launched
        p_hdesk_user_id     : fnd user id of the help desk user id setup in GCD. Optional,
                              if not passed will be derived from GCD.

    If no vendor/merchant contact bases on jtf object 'OKX_SALEPERS' can be found for the contract
    header, the help desk user is used. This behaviour is from R12 onwards, prior to this if a
    salesrep was not found, contract admin and then contract approver would be used.
    */
    PROCEDURE GET_USER_NAME
    (
     p_api_version IN NUMBER DEFAULT 1,
     p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     p_chr_id IN NUMBER,
     p_hdesk_user_id IN NUMBER,
     x_user_id OUT NOCOPY NUMBER,
     x_user_name OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'GET_USER_NAME';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    --should be an outer join with party roles, so that
    --if we don't get a vendor/merchant party we atleast get an org
    CURSOR c_k_hdr(cp_chr_id IN NUMBER) IS
        SELECT nvl(a.org_id, a.authoring_org_id), b.id
        FROM okc_k_headers_all_b a LEFT OUTER JOIN okc_k_party_roles_b b
        ON  a.id = b.dnz_chr_id
        AND b.cle_id IS NULL
        AND b.rle_code IN ('VENDOR', 'MERCHANT')
        WHERE a.id = cp_chr_id;

    CURSOR c_k_srep_user(cp_chr_id IN NUMBER, cp_cpl_id IN NUMBER, cp_org_id IN NUMBER) IS
        SELECT
        --rsc.resource_id, srp.salesrep_id, srp.org_id, ctc.cro_code,
        fnd.user_id, fnd.user_name
        FROM okc_contacts ctc,  fnd_user fnd,
            jtf_rs_resource_extns rsc, jtf_rs_salesreps srp
        WHERE ctc.dnz_chr_id = cp_chr_id
        AND ctc.cpl_id = cp_cpl_id
        AND ctc.cro_code IN (SELECT  src.cro_code FROM okc_contact_sources src
                                WHERE src.rle_code IN ('VENDOR', 'MERCHANT')
                                AND src.jtot_object_code = 'OKX_SALEPERS'
                                AND src.buy_or_sell = 'S')
        AND srp.salesrep_id = to_number(ctc.object1_id1)
        AND nvl(srp.org_id, -99) = cp_org_id
        AND srp.resource_id = rsc.resource_id
        AND rsc.user_id = fnd.user_id;

    CURSOR c_fnd_user(cp_user_id IN NUMBER) IS
        SELECT user_name
        FROM fnd_user
        WHERE user_id = cp_user_id;

    l_org_id        NUMBER;
    l_cpl_id        NUMBER;
    l_user_id       NUMBER;
    l_user_name     VARCHAR2(100);

    l_rnrl_rec      OKS_RENEW_UTIL_PVT.rnrl_rec_type;
    x_rnrl_rec      OKS_RENEW_UTIL_PVT.rnrl_rec_type;

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id||' ,p_hdesk_user_id='||p_hdesk_user_id);
        END IF;

        --standard api initilization and checks
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --first get the contract org and id for the merchant/vendor record in okc_k_party_roles_b
        OPEN c_k_hdr(p_chr_id);
        FETCH c_k_hdr INTO l_org_id, l_cpl_id;
        CLOSE c_k_hdr;

        IF (l_org_id IS NULL) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INV_CONTRACT');
            FND_MESSAGE.set_token('CONTRACT_ID', p_chr_id);
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.basic_validation', FALSE);
            END IF;
            FND_MSG_PUB.ADD;
            RAISE FND_API.g_exc_error;
        END IF;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_org_cpl', 'l_org_id=' || l_org_id||' ,l_cpl_id='||l_cpl_id);
        END IF;

        --now get the fnd user id/name for the contact of type 'OKX_SALEPERS', if a vendor/merchant party
        --is found
        IF (l_cpl_id IS NOT NULL) THEN

            OPEN c_k_srep_user(p_chr_id, l_cpl_id, l_org_id);
            FETCH c_k_srep_user INTO l_user_id, l_user_name;
            CLOSE c_k_srep_user;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_k_user', 'l_user_id='||l_user_id||' , l_user_name='||l_user_name);
            END IF;

        END IF;

        --if no salesrep found, default to helpdesk user
        IF (l_user_id IS NULL) THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_helpdesk_user', 'no salesrep found in contract, getting the helpdesk user');
            END IF;

            IF (p_hdesk_user_id IS NOT NULL) THEN
                l_user_id := p_hdesk_user_id;
            ElSE
                --get the helpdesk user id from GCD
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calling_get_renew_rules', 'p_chr_id=' || p_chr_id ||', p_date='|| sysdate);
                END IF;

                OKS_RENEW_UTIL_PVT.get_renew_rules(
                                x_return_status => x_return_status,
                                p_api_version => 1.0,
                                p_init_msg_list => FND_API.G_FALSE,
                                p_chr_id => p_chr_id,
                                p_party_id => NULL,
                                p_org_id => NULL,
                                p_date => sysdate,
                                p_rnrl_rec => l_rnrl_rec,
                                x_rnrl_rec => x_rnrl_rec,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.after_get_renew_rules', 'x_return_status=' || x_return_status ||' ,l_user_id='|| x_rnrl_rec.user_id);
                END IF;
                IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                END IF;

                l_user_id := x_rnrl_rec.user_id;

            END IF;

            --commented out, do not throw error if no helpdesk setup
            --so that renewal can continue
            /*
            IF (l_user_id IS NULL) THEN
                FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_NO_HELPDESK');
                IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.message(FND_LOG.level_error, l_mod_name || '.get_helpdesk_user', FALSE);
                END IF;
                FND_MSG_PUB.ADD;
                RAISE FND_API.g_exc_error;
            END IF;
            */

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_helpdesk_user', 'getting user name for user id='||l_user_id);
            END IF;

            OPEN c_fnd_user(l_user_id);
            FETCH c_fnd_user INTO l_user_name;
            CLOSE c_fnd_user;
        END IF;
        x_user_id := l_user_id;
        x_user_name := l_user_name;


        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status||' ,x_user_id='||x_user_id||' ,x_user_name='||x_user_name);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            IF (c_k_srep_user%isopen) THEN
                CLOSE c_k_srep_user;
            END IF;
            IF (c_fnd_user%isopen) THEN
                CLOSE c_fnd_user;
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            IF (c_k_srep_user%isopen) THEN
                CLOSE c_k_srep_user;
            END IF;
            IF (c_fnd_user%isopen) THEN
                CLOSE c_fnd_user;
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            IF (c_k_srep_user%isopen) THEN
                CLOSE c_k_srep_user;
            END IF;
            IF (c_fnd_user%isopen) THEN
                CLOSE c_fnd_user;
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    END GET_USER_NAME;


    /*
	From R12 onwards, this procedure should be used to renew service contracts.
    It will be redesigned to do the following
        1.	Improve performance
        2.	Reduce dependence on OKC code
        3.	Incorporate functional design changes for R12
        4.	Comply with current Oracle Applications coding and logging standards
        5.	Ease of maintenance

    Parameters
        p_chr_id                    :   id of the contract being renewed, mandatory
        p_new_contract_number       :   contract number for the renewed contract, optional
        p_new_contract_modifier     :   contract modifier for the renewed contract, optional
        p_new_start_date            :   start date for the renewed contract, optional
        p_new_end_date              :   end date for the renewed contract, optional
        p_new_duration              :   duration for renewed contract, optional
        p_new_uom_code              :   period for the renewed contract, optional
        p_renewal_called_from_ui    :  'Y' - called from UI, N - called from Events
        x_chr_id                :   id of the renewed contract
        x_return_status             :   S, E, U - standard values

    Defaulting rules
        1. If p_new_contract_number is not passed, uses the source contract_number
        2. If p_new_contract_modifier is not passed, generated this as
            fnd_profile.VALUE('OKC_CONTRACT_IDENTIFIER') || to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
        3. If p_new_start_date is not passed, defaults to source contract end_date +1
        4. If p_new_end_date is not passed, derived from p_new_duration/p_new_uom_code
            and p_new_start_date. If p_new_duration/p_new_uom_code are also not passed
            used the source contract duration/period
    */

    PROCEDURE RENEW_CONTRACT
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_commit   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_chr_id IN NUMBER,
     p_new_contract_number IN okc_k_headers_b.contract_number%TYPE,
     p_new_contract_modifier IN okc_k_headers_b.contract_number_modifier%TYPE,
     p_new_start_date IN DATE,
     p_new_end_date IN DATE,
     p_new_duration IN NUMBER,
     p_new_uom_code IN MTL_UNITS_OF_MEASURE_TL.uom_code%TYPE,
     p_renewal_called_from_ui IN VARCHAR2 DEFAULT 'Y',
     x_chr_id OUT NOCOPY NUMBER,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
     )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'RENEW_CONTRACT';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    --also check if it is a service contract
    CURSOR c_k_hdr(cp_chr_id IN NUMBER) IS
        SELECT contract_number, contract_number_modifier, start_date, end_date,
        renewal_type_code, renewal_end_date, currency_code
        FROM okc_k_headers_all_b
        WHERE id = cp_chr_id AND application_id = 515;

    CURSOR c_renk_hdr(cp_chr_id IN NUMBER) IS
        SELECT currency_code, org_id
        FROM okc_k_headers_all_b WHERE id = cp_chr_id;


    l_k_num                 okc_k_headers_b.contract_number%TYPE;
    l_k_mod                 okc_k_headers_b.contract_number_modifier%TYPE;
    l_k_start_date          DATE;
    l_k_end_date            DATE;
    l_k_ren_type            okc_k_headers_b.renewal_type_code%TYPE;
    l_k_renewal_end_date    DATE;
    l_k_currency_code       VARCHAR2(15);

    l_validation_level      VARCHAR2(1);
    l_rnrl_rec              OKS_RENEW_UTIL_PVT.rnrl_rec_type;
    l_rnrl_rec_dummy        OKS_RENEW_UTIL_PVT.rnrl_rec_type;
    l_validation_status     VARCHAR2(1);
    l_validation_tbl        validation_tbl_type;

    l_renk_num              okc_k_headers_b.contract_number%TYPE;
    l_renk_mod              okc_k_headers_b.contract_number_modifier%TYPE;
    l_renk_start_date       DATE;
    l_renk_end_date         DATE;
    l_renk_currency_code    VARCHAR2(15);
    l_renk_org_id           NUMBER;

    l_user_id               NUMBER;
    l_user_name             VARCHAR2(100);
    l_renewal_type          VARCHAR2(30);
    l_approval_type         VARCHAR2(30);
    l_warnings              BOOLEAN := FALSE;

    BEGIN
        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_procedure, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_api_version=' || p_api_version ||' ,p_commit='|| p_commit ||' ,p_chr_id='|| p_chr_id||' , p_new_contract_number='||p_new_contract_number||
                ' ,p_new_contract_modifier='||p_new_contract_modifier||' ,p_new_start_date='||p_new_start_date||' ,p_new_end_date='||p_new_end_date||
                ' ,p_new_duration='||p_new_duration||' ,p_new_uom_code='||p_new_uom_code||' ,p_renewal_called_from_ui='||p_renewal_called_from_ui);
            END IF;
        END IF;

	 -- Put the parameters in the log file
         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Calling OKS_RENEW_CONTRACT_PVT.RENEW_CONTRACT');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'Parameters  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'p_api_version :  '||p_api_version);
         fnd_file.put_line(FND_FILE.LOG,'p_init_msg_list :  '||p_init_msg_list);
         fnd_file.put_line(FND_FILE.LOG,'p_commit :  '||p_commit);
         fnd_file.put_line(FND_FILE.LOG,'p_chr_id :  '||p_chr_id);
         fnd_file.put_line(FND_FILE.LOG,'p_new_contract_number :  '||p_new_contract_number);
         fnd_file.put_line(FND_FILE.LOG,'p_new_contract_modifier :  '||p_new_contract_modifier);
         fnd_file.put_line(FND_FILE.LOG,'p_new_start_date :  '||p_new_start_date);
         fnd_file.put_line(FND_FILE.LOG,'p_new_end_date :  '||p_new_end_date);
         fnd_file.put_line(FND_FILE.LOG,'p_new_duration :  '||p_new_duration);
         fnd_file.put_line(FND_FILE.LOG,'p_new_uom_code :  '||p_new_uom_code);
         fnd_file.put_line(FND_FILE.LOG,'p_renewal_called_from_ui :  '||p_renewal_called_from_ui);
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');


        --standard api initilization and checks
        SAVEPOINT renew_contract_PVT;
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

	    /*
	        Step 1: do basic parameter validation
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 1: do basic parameter validation  ');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 1 do basic parameter validation
        --first get the basic contract attributes
        OPEN c_k_hdr(p_chr_id);
        FETCH c_k_hdr INTO l_k_num, l_k_mod, l_k_start_date, l_k_end_date, l_k_ren_type,
        l_k_renewal_end_date, l_k_currency_code;

        --invalid contract id or if it's not a service contract
        IF (c_k_hdr%notfound) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INV_CONTRACT');
            FND_MESSAGE.set_token('CONTRACT_ID', p_chr_id);
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.basic_validation1', FALSE);
            END IF;
            FND_MSG_PUB.ADD;
            CLOSE c_k_hdr;
            RAISE FND_API.g_exc_error;
        END IF;
        CLOSE c_k_hdr;

        --new start date < original end date
        IF (p_new_start_date IS NOT NULL) AND (p_new_start_date < l_k_end_date) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_NEW_START_MORE_END');
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.basic_validation2', FALSE);
            END IF;
            FND_MSG_PUB.ADD;
            RAISE FND_API.g_exc_error;
        END IF;

        --new end date < new start date, if new start date is null use old end date + 1
        IF (p_new_end_date IS NOT NULL) AND (p_new_end_date < nvl(p_new_start_date, l_k_end_date + 1)) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INVALID_END_DATE');
            FND_MESSAGE.set_token('START_DATE', to_char(nvl(p_new_start_date, l_k_end_date + 1)));
            FND_MESSAGE.set_token('END_DATE', to_char(p_new_end_date));
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.basic_validation3', FALSE);
            END IF;
            FND_MSG_PUB.ADD;
            RAISE FND_API.g_exc_error;
        END IF;
        --end basic parameter validation

	    /*
	        Step 2: do renewal validation and at the same time fetch the renewal rules
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 2: do renewal validation and at the same time fetch the renewal rules  ');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 2 do renewal validation and at the same time fetch the renewal rules
        --if called from UI, then user has ready seen the warnings, so we check only for errors
        --if called from Events, we need to check for both errors and warnings
        IF (p_renewal_called_from_ui = 'Y') THEN
            l_validation_level := G_VALIDATE_ERRORS;
        ELSE
            l_validation_level := G_VALIDATE_ALL;
        END IF;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.renewal_validation', 'calling OKS_RENEW_UTIL_PVT.validate_renewal, p_chr_id='||p_chr_id||' ,p_date='||to_char(nvl(p_new_start_date, l_k_end_date + 1))||
            ' ,p_validation_level='||l_validation_level);
        END IF;

        validate_renewal(
            p_api_version =>  1,
            p_init_msg_list => FND_API.G_FALSE,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_chr_id => p_chr_id,
            p_date => nvl(p_new_start_date, l_k_end_date + 1),
            p_validation_level => l_validation_level,
            x_rnrl_rec => l_rnrl_rec,
            x_validation_status => l_validation_status,
            x_validation_tbl => l_validation_tbl);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.renewal_validation', 'after call to OKS_RENEW_UTIL_PVT.validate_renewal, x_return_status='||x_return_status||' ,x_validation_status='||l_validation_status);
        END IF;

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        --if validation errors - stop
        --if validation warnings - stop if called from events
        IF (    (l_validation_status = G_VALID_STS_ERROR) OR
                (   (l_validation_status = G_VALID_STS_WARNING) AND
                (p_renewal_called_from_ui = 'N')    )
        ) THEN
            --add all validation messages to the FND_MSG_PUB stack
            FOR i in l_validation_tbl.FIRST..l_validation_tbl.LAST LOOP
                --OKS_USER_DEFINED_MESSAGE is a special message, with the message body = MESSAGE
                --This is a workaround, because we can't directly add messages to the msg API list
                --using FND_MSG_PUB.add. FND_MSG_PUB.add expects messages on the message stack (FND_MESSAGE.set_name)
                FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_USER_DEFINED_MESSAGE');
                FND_MESSAGE.set_token('MESSAGE', l_validation_tbl(i).message);
                FND_MSG_PUB.add;
            END LOOP;
            RAISE FND_API.g_exc_error;
        END IF;
        --end renewal validation

	    /*
	        Step 3: default attributes
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 3: default attributes ');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 3 default attributes
        l_renk_num := nvl(p_new_contract_number, l_k_num);
        l_renk_mod := nvl(p_new_contract_modifier, fnd_profile.VALUE('OKC_CONTRACT_IDENTIFIER') || to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
        l_renk_start_date := trunc(nvl(p_new_start_date, l_k_end_date + 1));
        l_renk_end_date := get_end_date(
                            p_new_start_date => l_renk_start_date,
                            p_new_end_date => p_new_end_date,
                            p_new_duration => p_new_duration,
                            p_new_uom_code => p_new_uom_code,
                            p_old_start_date => l_k_start_date,
                            p_old_end_date => l_k_end_date,
                            p_renewal_end_date => l_k_renewal_end_date,
                            p_ren_type => l_k_ren_type,
                            x_return_status => x_return_status);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.default_attributes', 'done   l_renk_num='||l_renk_num||' ,l_renk_mod='||l_renk_mod||' ,l_renk_start_date='||to_char(l_renk_start_date)||
            ' ,l_renk_end_date='||to_char(l_renk_end_date)||' ,x_return_status='||x_return_status);
        END IF;
        --end default attributes

	    /*
	        Step 4: copy contract
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 4: copy contract ');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 4 copy contract
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.copy_contract', 'calling OKC_COPY_CONTRACT_PUB.copy_contract, p_chr_id='||p_chr_id||' ,p_contract_number='||l_renk_num||' ,p_contract_number_modifier='||l_renk_mod||
            ' ,p_to_template_yn=N, p_renew_ref_yn=Y, p_override_org=Y, p_copy_lines_yn=Y ,p_commit=F');
        END IF;

        OKS_COPY_CONTRACT_PVT.copy_contract(
            p_api_version  => 1,
            p_init_msg_list => FND_API.G_FALSE,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_commit => FND_API.G_FALSE,
            p_chr_id => p_chr_id,
            p_contract_number => l_renk_num,
            p_contract_number_modifier => l_renk_mod,
            p_to_template_yn => 'N',
            P_renew_ref_yn => 'Y',
            x_to_chr_id => x_chr_id);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.copy_contract', 'after call to OKC_COPY_CONTRACT_PUB.copy_contract, x_return_status='||x_return_status||' ,x_chr_id='||x_chr_id);
        END IF;

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        --sales credit and copy are the 2 places we can return with a warning
        IF x_return_status = OKC_API.g_ret_sts_warning THEN -- 'W'
            l_warnings := TRUE;
        END IF;
        --end copy contract

	    /*
	        Step 5: if the renewed contract currency is different from original contract currency
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 5:if the renewed contract currency is different');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 5 if the renewed contract currency is different from original contract currency
        --get the renewal rules again, as thresholds depend on currency
        OPEN c_renk_hdr(x_chr_id);
        FETCH c_renk_hdr INTO l_renk_currency_code, l_renk_org_id;
        CLOSE c_renk_hdr;

        IF (l_renk_currency_code <> l_k_currency_code) THEN

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calling_get_renew_rules', 'p_chr_id=' || x_chr_id ||', p_date='|| l_renk_start_date||' ,l_k_currency_code='||l_k_currency_code||' ,l_renk_currency_code='||l_renk_currency_code);
            END IF;

            OKS_RENEW_UTIL_PVT.get_renew_rules(
                            x_return_status => x_return_status,
                            p_api_version => 1.0,
                            p_init_msg_list => FND_API.G_FALSE,
                            p_chr_id => x_chr_id,
                            p_party_id => NULL,
                            p_org_id => NULL,
                            p_date => l_renk_start_date,
                            p_rnrl_rec => l_rnrl_rec_dummy,
                            x_rnrl_rec => l_rnrl_rec,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.after_get_renew_rules', 'x_return_status=' || x_return_status);
            END IF;
            IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
            ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
            END IF;

        END IF;
        --end of currency/renewal rules check

	    /*
	        Step 6: adjust the header and line dates
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 6 : adjust the header and line dates');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 6 adjust the header and line dates
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_dates', 'calling  update_renewal_dates, p_chr_id='||x_chr_id||' ,p_new_start_date='||l_renk_start_date||
            ' ,p_new_end_date='||l_renk_end_date||' ,p_old_start_date='||l_k_start_date);
        END IF;
        update_renewal_dates(
            p_chr_id  => x_chr_id,
            p_new_start_date => l_renk_start_date,
            p_new_end_date => l_renk_end_date,
            p_old_start_date => l_k_start_date,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_return_status => x_return_status);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_dates', 'after  update_renewal_dates, x_return_status='||x_return_status);
        END IF;
        --end of adjust dates

 	    /*
	        Step 6.1 : Update annualized_factor for the renewed contract lines
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 6.1 : Update annualized_factor for the renewed contract lines');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        -- Step 6.1 Update annualized_factor for the renewed contract lines
        -- bug 4768227
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name , ' calling  update to annualized_factor , p_new_chr_id='||x_chr_id);
        END IF;

          UPDATE okc_k_lines_b
             SET annualized_factor = OKS_SETUP_UTIL_PUB.Get_Annualized_Factor(start_date, end_date, lse_id)
           WHERE dnz_chr_id = x_chr_id;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name , ' After calling  update to annualized_factor , p_new_chr_id='||x_chr_id);
        END IF;

	    /*
	        Step 7: update the old contract's date renewed column for the lines that are actually renewed
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 7 : update the old contract date renewed column for the lines that are actually renewed');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 7 update the old contract's date renewed column for the lines that are actually renewed
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_source_contract', 'calling  update_source_contract, p_new_chr_id='||x_chr_id||' ,p_old_chr_id='||p_chr_id);
        END IF;
        update_source_contract(
            p_new_chr_id  => x_chr_id,
            p_old_chr_id => p_chr_id,
            x_return_status => x_return_status);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_source_contract', 'after  update_source_contract, x_return_status='||x_return_status);
        END IF;
        --end of adjust date

	    /*
	        Step 8: adjust the invoice text that is based on the line dates
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 8 : adjust the invoice text that is based on the line dates');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --now adjust all date dependent entities
        --Step 8 adjust the invoice text that is based on the line dates
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.invoice_text', 'calling  update_invoice_text, p_chr_id='||x_chr_id);
        END IF;
        update_invoice_text(
            p_api_version => 1,
            p_init_msg_list => FND_API.G_FALSE,
            p_commit => FND_API.G_FALSE,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_chr_id  => x_chr_id);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.invoice_text', 'after  update_invoice_text, x_return_status='||x_return_status);
        END IF;
        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;
        --end of invoice text

        /*
         bug 4775295 : Commented call to procedure update_condition_headers

        --Step 9 update contract condition(event) headers
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.condition_header', 'calling  update_condition_headers, p_chr_id='||x_chr_id||' ,p_new_start_date='||l_renk_start_date||' ,p_new_end_date='||l_renk_end_date
            ||' ,p_old_start_date='||l_k_start_date||' ,p_old_end_date='||l_k_end_date);
        END IF;

        update_condition_headers(
            p_chr_id => x_chr_id,
            p_new_start_date => l_renk_start_date,
            p_new_end_date => l_renk_end_date,
            p_old_start_date => l_k_start_date,
            p_old_end_date => l_k_end_date,
            x_return_status => x_return_status);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.condition_header', 'after  update_condition_headers, x_return_status='||x_return_status);
        END IF;
        --end of contract condition(event) headers

         */

	    /*
	        Step 10: adjust the header and line dates
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 10 : Regenerate subscription schedule/details and coverage entities based on the new dates');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 10 Regenerate subscription schedule/details and coverage entities based on the new dates
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.coverage_subscription', 'calling  recreate_cov_subscr, p_chr_id='||x_chr_id);
        END IF;
        recreate_cov_subscr(
            p_chr_id => x_chr_id,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_return_status => x_return_status);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.coverage_subscription', 'after  call to recreate_cov_subscr, x_return_status='||x_return_status);
        END IF;
        --end of coverage/subscription recreation

	    /*
	        Step 11: adjust the header and line dates
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 11 : Call pricing API to reprice the contract based on new dates');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 11 Call pricing API to reprice the contract based on new dates
        --and renewal pricing rules. This will also rollup price/tax values at the topline and header
        --level and stamp the pricelist on the lines.
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.repricing', 'calling  reprice_contract, p_chr_id='||x_chr_id||' ,p_price_method='||l_rnrl_rec.renewal_pricing_type||' ,p_price_list_id='||l_rnrl_rec.price_list_id1
            ||' ,p_markup_percent='||l_rnrl_rec.markup_percent);
        END IF;

        reprice_contract(
            p_chr_id  => x_chr_id,
            p_price_method => l_rnrl_rec.renewal_pricing_type,
            p_price_list_id => l_rnrl_rec.price_list_id1,
            p_markup_percent => l_rnrl_rec.markup_percent,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_return_status => x_return_status);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.repricing', 'after  call to reprice_contract, x_return_status='||x_return_status);
        END IF;
        --end of repricing

	    /*
	        Step 12 : copy usage price locks if any
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 12 : copy usage price locks if any');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 12 copy usage price locks if any
        --Can be done only after the line pricelist has been updated (in reprice_contract)
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.usage_price_locks', 'calling  copy_usage_price_locks, p_chr_id='||x_chr_id||' ,p_contract_number='||l_renk_num);
        END IF;
        copy_usage_price_locks(
            p_chr_id  => x_chr_id,
            p_org_id => l_renk_org_id,
            p_contract_number => l_renk_num,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_return_status => x_return_status);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.usage_price_locks', 'after  call to copy_usage_price_locks, x_return_status='||x_return_status);
        END IF;
        --end of copy usage price locks


	    /*
	        Step 13: adjust the header and line dates
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 13 : Recreate billing schedules for the lines/header');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 13 Recreate billing schedules for the lines/header.
        --Can be done only after dates adjustment and repricing the contract
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.billing', 'calling  recreate_billing, p_chr_id='||x_chr_id);
        END IF;
        recreate_billing(
            p_chr_id  => x_chr_id,
            p_billing_profile_id => l_rnrl_rec.billing_profile_id,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_return_status => x_return_status);
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.billing', 'after  call to recreate_billing, x_return_status='||x_return_status);
        END IF;
        --end of billing

	    /*
	        Step 14 : Process Sales credits
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 14 : Process Sales credits');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 14 Process Sales credits
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.sales_credits', 'calling  process_sales_credit, p_chr_id='||x_chr_id);
        END IF;

        fnd_file.put_line(FND_FILE.LOG,'Calling process_sales_credit ');

        process_sales_credit(
            p_chr_id  => x_chr_id,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_return_status => x_return_status);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.sales_credits', 'after  call to process_sales_credit, x_return_status='||x_return_status);
        END IF;

        --sales credit and copy are the 2 places we can return with a warning
        IF x_return_status = OKC_API.g_ret_sts_warning THEN -- 'W'
            l_warnings := TRUE;
        END IF;
        --end of sales credits

	    /*
	        Step 15 : get the user id and name (salesperson) of the contact
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 15 : get the user id and name (salesperson) of the contact');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 15 get the user id and name (salesperson) of the contact who will be
        --the performer for the workflow. Can be done only after sales credits
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_user_name', 'calling  get_user_name, p_chr_id='||x_chr_id||' ,p_hdesk_user_id='||l_rnrl_rec.user_id);
        END IF;

        get_user_name(
            p_api_version =>  1,
            p_init_msg_list => FND_API.G_FALSE,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_chr_id => x_chr_id,
            p_hdesk_user_id => l_rnrl_rec.user_id,
            x_user_id => l_user_id,
            x_user_name => l_user_name);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_user_name', 'after call to  get_user_name, x_return_status='||x_return_status||' ,l_user_id='||l_user_id||' ,l_user_name='||l_user_name);
        END IF;
        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;
        --end of get user name

	    /*
	        Step 16: check and assign contract to contract group specified in GCD
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 16 : check and assign contract to contract group specified in GCD');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 16 check and assign contract to contract group specified in GCD
        IF( l_rnrl_rec.cgp_renew_id IS NOT NULL) THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.contract_group', 'calling assign_contract_group p_chr_id='||p_chr_id||' ,p_chr_group_id='||l_rnrl_rec.cgp_renew_id);
            END IF;
            assign_contract_group(
                p_chr_id  => x_chr_id,
                p_chr_group_id => l_rnrl_rec.cgp_renew_id,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                x_return_status => x_return_status);
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.contract_group', 'after  call to assign_contract_group, x_return_status='||x_return_status);
            END IF;
        END IF;
        --end of contract group
	    /*
	        Step 17: check and update/create contract approval process specified in GCD
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 17 : check and update/create contract approval process specified in GCD');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 17 check and update/create contract approval process specified in GCD
        IF( l_rnrl_rec.pdf_id IS NOT NULL) THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.contract_process', 'calling assign_contract_process p_chr_id='||p_chr_id||' ,p_pdf_id='||l_rnrl_rec.pdf_id);
            END IF;
            assign_contract_process(
                p_chr_id  => x_chr_id,
                p_pdf_id => l_rnrl_rec.pdf_id,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data,
                x_return_status => x_return_status);
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.contract_process', 'after  call to assign_contract_process, x_return_status='||x_return_status);
            END IF;
        END IF;
        --end of contract approval process

	    /*
	        Step 18: update contract (OKC and OKS) with the renewal rules
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 18 : update contract (OKC and OKS) with the renewal rules');
         fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        --Step 18 update contract (OKC and OKS) with the renewal rules, inlcuding determination
        --renewal type and launching/modification of workflow
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_contract', 'calling update_renewed_contract p_chr_id='||p_chr_id||' ,p_notify_to='||l_user_id);
        END IF;
        update_renewed_contract(
            p_chr_id  => x_chr_id,
            p_rnrl_rec => l_rnrl_rec,
            p_notify_to => l_user_id,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_return_status => x_return_status);
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.update_contract', 'after  call to update_renewed_contract, x_return_status='||x_return_status);
        END IF;
        --end of update contract

        IF (l_warnings) THEN
           x_return_status :=  OKC_API.G_RET_STS_WARNING;
        END IF;

        --standard check of p_commit
	    IF FND_API.to_boolean( p_commit ) THEN
		    COMMIT;
	    END IF;

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Completed Calling OKS_RENEW_CONTRACT_PVT.RENEW_CONTRACT');
         fnd_file.put_line(FND_FILE.LOG,'End Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_procedure, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_chr_id=' || x_chr_id ||', x_return_status='|| x_return_status);
            END IF;
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            ROLLBACK TO renew_contract_PVT;
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );
            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            IF (c_renk_hdr%isopen) THEN
                CLOSE c_renk_hdr;
            END IF;

        WHEN FND_API.g_exc_unexpected_error THEN
            ROLLBACK TO renew_contract_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );
            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            IF (c_renk_hdr%isopen) THEN
                CLOSE c_renk_hdr;
            END IF;

        WHEN OTHERS THEN
            ROLLBACK TO renew_contract_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );
            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;
            IF (c_renk_hdr%isopen) THEN
                CLOSE c_renk_hdr;
            END IF;

    END RENEW_CONTRACT;


END OKS_RENEW_CONTRACT_PVT;

/
