import React, { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';

axios.defaults.baseURL = 'http://localhost:5000';
axios.defaults.withCredentials = true;

const CartContext = createContext();
export const useCart = () => useContext(CartContext);

export const CartProvider = ({ children }) => {
    const [cart, setCart] = useState([]);

    const addToCart = (product) => setCart([...cart, product]);
    const removeFromCart = (id) => setCart(cart.filter(item => item.id !== id));

    const handlePayment = async () => {
        const total = cart.reduce((acc, item) => acc + item.price, 0);
        try {
            await axios.post('/transactions', {
                products: cart,
                total,
            });
            alert('Płatność przetworzona i zapisana!');
            setCart([]);
        } catch (error) {
            console.error('Błąd płatności:', error);
        }
    };

    return (
        <CartContext.Provider value={{ cart, addToCart, removeFromCart, handlePayment }}>
            {children}
        </CartContext.Provider>
    );
};

const ProductList = () => {
    const [products, setProducts] = useState([]);
    const [categories, setCategories] = useState([]);
    const [selectedCategory, setSelectedCategory] = useState('Wszystkie');
    const { addToCart } = useCart();

    useEffect(() => {
        axios.get('/products').then(res => setProducts(res.data)).catch(console.error);
        axios.get('/categories').then(res => setCategories(res.data)).catch(console.error);
    }, []);

    const filteredProducts = selectedCategory === 'Wszystkie' ? products : products.filter(p => p.category === selectedCategory);

    return (
        <div>
            <h1>Produkty</h1>
            <select onChange={(e) => setSelectedCategory(e.target.value)}>
                <option value="Wszystkie">Wszystkie</option>
                {categories.map(category => <option key={category.id} value={category.name}>{category.name}</option>)}
            </select>
            <ul>
                {filteredProducts.map(product => (
                    <li key={product.id}>{product.name} - ${product.price} <button onClick={() => addToCart(product)}>Dodaj do koszyka</button></li>
                ))}
            </ul>
        </div>
    );
};

const Cart = () => {
    const { cart, removeFromCart, handlePayment } = useCart();

    return (
        <div>
            <h1>Koszyk</h1>
            <ul>
                {cart.map(item => (
                    <li key={item.id}>{item.name} - ${item.price} <button onClick={() => removeFromCart(item.id)}>Usuń</button></li>
                ))}
            </ul>
            {cart.length > 0 && <button onClick={handlePayment}>Zapłać</button>}
        </div>
    );
};

const App = () => (
    <CartProvider>
        <ProductList />
        <Cart />
    </CartProvider>
);

export default App;