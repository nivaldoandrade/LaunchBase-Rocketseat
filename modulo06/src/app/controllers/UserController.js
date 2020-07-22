const User = require('../models/User');
const { formatCep, formatCpfCnpj } = require('../../lib/utils'); 

module.exports = {
    registerForm(req, res) {
        return res.render("users/register");
    },
    async show(req, res) {

        const { user } = req

        user.cpf_cnpj = formatCpfCnpj(user.cpf_cnpj);
        user.cep = formatCep(user.cep);

        return res.render("users/index", { user });
    },
    async post(req, res) {

        const userId = await User.create(req.body);

        req.session.userId = userId;
       
        return res.redirect('/users');
    },
    async update(req, res) {
        try {
            const { user } = req;
            let { name, email, cpf_cnpj, cep, address } = req.body;

            cpf_cnpj = cpf_cnpj.replace(/\D/g, "");
            cep = cep.replace(/\D/g, "");

            await User.update(user.id, {
                name,
                email,
                cpf_cnpj,
                cep,
                address,
            });

            res.render('users/index', {
                user: req.body,
                success: 'Atualizado com sucesso!!'
            })
            
        } catch (error) {
            console.error(error);
            return {
                error: 'Ooooops, deu erro!!'
            }
        }

    },
    async delete(req, res) {
        await User.delete(req.body.id);

        req.session.destroy();

        return res.render("home/index",{
            success: 'Usuário deletado com sucesso.'
        })
    }
}