import type { Card } from "@prisma/client";
import { Prisma } from "./Utils/Prisma";
import { Token } from "./Utils/Token";
import { SecretKey } from "./Secure/SeckretKey";
import { Logger } from "./Utils/Logger";
import { Fetch } from "./Utils/Fetch";
import fs from 'fs-extra'


interface DataRequest {
    token: string
    login: string
    pass: string
    id_card: number
    uid_bank: string
    number_card: string
}

interface ResponseFetch {
    status: number
    message: string
}

class Daemon {

    private main_url: string = 'http://localhost:3006/micro/amount/';
    private sleep: number;

    constructor(sleep: number) {
        this.sleep = sleep
    }

    /*
    *** Sleep method
    */
    private async delay(time: number): Promise<void> {
        return new Promise(function (resolve) {
            setTimeout(resolve, time)
        });
    }

    /*
    *** Start daemon 
    */
    public async main(): Promise<void> {

        try {

            while (true) {

                const cards: Card[] | null = await Prisma.client.card.findMany();

                if (cards) {

                    for (const i of cards) {

                        const token: string = await Token.sign({ uid: 'uid' }, SecretKey.secret_key_micro, 1000);

                        const url: string = i.bank_uid === '111' ? ' sberbank_rub' : 'alfabank_rub'

                        const data: DataRequest = {
                            token: token,
                            login: i.card_login,
                            pass: i.card_password,
                            id_card: i.id,
                            uid_bank: i.bank_uid,
                            number_card: i.card_number
                        }

                        const fetch: ResponseFetch = await Fetch.request(`${this.main_url}${url}`, data);

                        if (fetch.status == 200) {
                            Logger.write(process.env.ERROR_LOGS, `Update card balans number: ${i.card_number} is done.`);
                        }

                        if (fetch.status != 200) {
                            Logger.write(process.env.ERROR_LOGS, `Update card balans number: ${i.card_number} is have error!!!!!!.`);
                        }

                    }
                }

                await this.delay(this.sleep * 1000)

            }

        }

        catch (e) {
            Logger.write(process.env.ERROR_LOGS, e);
        }

    }

}


(
    async () => {

        try {

            /*
            *** Read config for get time to sleep
            */
            const file: Buffer = await fs.readFile('config.json');

            const json: { sleep: number } = JSON.parse(file.toString());

            /*
            *** Start daemon
            */
            new Daemon(json.sleep).main()

        }
        catch (e) {
            Logger.write(process.env.ERROR_LOGS, e);
        }

    }
)()