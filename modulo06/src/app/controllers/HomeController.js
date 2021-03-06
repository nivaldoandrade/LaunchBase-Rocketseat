const { formatPrice } = require("../../lib/utils");
const Product = require("../models/Product");
const File = require("../models/File");


module.exports = {
    async index(req, res) {
        let result = await Product.all();
        const products = result.rows;      

        if(!products) return res.send("Products not found!");

        async function getImage(producutId) {
            let result = await Product.files(producutId);
            const files = result.rows.map(file => `${req.protocol}://${req.headers.host}${file.path.replace("public","")}`);

            return files[0];
        };

        const productsPromise = result.rows.map(async product => {
            product.img = await getImage(product.id);
            product.oldPrice = formatPrice(product.old_price);
            product.price = formatPrice(product.price);

            return product;
        }).filter((product, index) =>  index > 2 ? false : true);

        const lastAdded = await Promise.all(productsPromise);
        
        return res.render("home/index", { products: lastAdded})    
    },
}
